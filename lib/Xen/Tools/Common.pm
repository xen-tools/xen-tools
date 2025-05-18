# -*- perl -*

package Xen::Tools::Common;

=encoding utf8

=head1 NAME

Xen::Tools::Common - Common functions used in xen-tools' Perl scripts


=head1 SYNOPSIS

 use Xen::Tools::Common;

=cut

use warnings;
use strict;

use Exporter 'import';
use vars qw(@EXPORT_OK @EXPORT);

use English;
use File::Which;
# If not available, use =~ s/\A\s+|\s+\z//urg
use builtin qw(trim);

@EXPORT = qw(readConfigurationFile xenRunning runCommand setupAdminUsers
             findXenToolstack readCommand
             logprint_with_config logonly_with_config fail_with_config);

=head1 FUNCTIONS

=head2 readConfigurationFile

=begin doc

  Read the specified configuration file, and update our global configuration
 hash with the values found in it.

=end doc

=cut

sub readConfigurationFile ($$)
{
    my ($file, $CONFIG) = (@_);

    # Don't read the file if it doesn't exist.
    return if ( !-e $file );


    my $line = "";

    open( FILE, "<", $file ) or
        fail_with_config("Cannot read file '$file' - $!", $CONFIG);

    while ( defined( $line = <FILE> ) )
    {
        chomp $line;
        if ( $line =~ s/\\$// )
        {
            $line .= <FILE>;
            redo unless eof(FILE);
        }

        # Skip lines beginning with comments
        next if ( $line =~ /^([ \t]*)\#/ );

        # Skip blank lines
        next if ( length($line) < 1 );

        # Strip trailing comments.
        if ( $line =~ /([^#]*)\#(.*)/ )
        {
            $line = $1;
        }

        # Find variable settings
        if ( $line =~ /([^=]+)=([^\n]+)/ )
        {
            my $key = $1;
            my $val = $2;

            # Strip leading and trailing whitespace.
            $key =~ s/^\s+//;
            $key =~ s/\s+$//;
            $val =~ s/^\s+//;
            $val =~ s/\s+$//;

            # command expansion?
            if ( $val =~ /(.*)`([^`]+)`(.*)/ )
            {

                # store
                my $pre  = $1;
                my $cmd  = $2;
                my $post = $3;

                # get output
                my $output = `$cmd`;
                chomp($output);

                # build up replacement.
                $val = $pre . $output . $post;
            }

            # Store value.
            $CONFIG->{ $key } = $val;
        }
    }

    close(FILE);
}

=head2 xenRunning

=begin doc

  Test to see if the given instance is running.

=end doc

=cut

sub xenRunning ($$)
{
    my ($hostname, $CONFIG) = (@_);

    my $running = 0;

    unless ($CONFIG->{'xm'}) {
        warn "Couldn't determine Xen toolstack, skipping check for running DomUs.\n"
            unless $ENV{AS_INSTALLED_TESTING};
        return 0;
    }

    open( CMD, $CONFIG->{'xm'}." list $hostname 2>/dev/null |" ) or
      fail_with_config("Failed to run '".$CONFIG->{'xm'}." list $hostname'", $CONFIG);
    while (<CMD>)
    {
        my $line = $_;
        $running = 1 if ( $line =~ /\Q$hostname\E/ );
    }
    close(CMD);

    return ($running);
}

=head2 findXenToolstack

=begin doc

  Find the right Xen toolstack. On Debian and derivatives there's a
 script which tells you about the current toolstack.

=end doc

=cut

sub findXenToolstack
{
    my $helper = '/usr/lib/xen-common/bin/xen-toolstack';

    my $xm = which('xm');
    my $xl = which('xl');

    if ($xm and $xl and -x $helper) {
        my $toolstack = `$helper`;
        chomp($toolstack);
        return $toolstack if $toolstack;
    }

    if ($xm and system("$xm list >/dev/null 2>/dev/null") == 0) {
        return $xm;
    }

    if ($xl and system("$xl list >/dev/null 2>/dev/null") == 0) {
        return $xl;
    }

    return undef;
}

=head2 runCommand

=begin doc

  A utility method to run a system command.  We will capture the return
 value and exit if the command files.

  When running verbosely we will also display any command output once
 it has finished.

=end doc

=cut

sub runCommand ($$;$)
{
    local $| = 1;
    my ($cmd, $CONFIG, $fail_ok) = (@_);

    #
    #  Set a local if we don't have one.
    #
    $ENV{ 'LC_ALL' } = "C" unless ( $ENV{ 'LC_ALL' } );

    #
    #  Header.
    #
    if ($CONFIG->{ 'verbose' }) {
        logprint_with_config("Executing : $cmd\n", $CONFIG);
    }

    #
    #  Copy stderr to stdout, so we can see it, and make sure we log it.
    #
    $cmd .= " 2>&1";

    #
    #  Run it.
    #
    my $rcopen = open(CMD, '-|', $cmd);
    if (!defined($rcopen)) {
        logprint_with_config("Starting command '$cmd' failed: $!\n", $CONFIG);
        unless ($fail_ok) {
            logprint_with_config("Aborting\n", $CONFIG);
            print "See /var/log/xen-tools/".$CONFIG->{'hostname'}.".log for details\n";
            $CONFIG->{'FAIL'} = 1;
            exit 127;
        }
    }

    while (my $line = <CMD>) {
        if ($CONFIG->{ 'verbose' }) {
            logprint_with_config($line, $CONFIG);
        } else {
            logonly_with_config($line, $CONFIG);
        }
    }

    my $rcclose = close(CMD);

    if ($CONFIG->{ 'verbose' }) {
        logprint_with_config("Finished : $cmd\n", $CONFIG);
    }

    if (!$rcclose)
    {
        my $exit_code = $? >> 8;
        logprint_with_config("Running command '$cmd' failed with exit code $exit_code.\n", $CONFIG);
        logprint_with_config("Aborting\n", $CONFIG);
        print "See /var/log/xen-tools/".$CONFIG->{'hostname'}.".log for details\n";
        unless ($fail_ok) {
            $CONFIG->{'FAIL'} = 1;
            exit 127;
        }
    }

}

=head2 readCommand

=begin doc

  A utility method to read a system command.  We will capture the return
 value and exit if the command files.

  The stdout of the command is returned

=end doc

=cut

sub readCommand ($$;$)
{
    local $| = 1;
    my ($cmd, $CONFIG, $fail_ok) = (@_);

    #
    #  Set a local if we don't have one.
    #
    $ENV{ 'LC_ALL' } = "C" unless ( $ENV{ 'LC_ALL' } );

    #
    #  Header.
    #
    if ($CONFIG->{ 'verbose' }) {
        logprint_with_config("Executing : $cmd\n", $CONFIG);
    }

    my $result = do {
        local $/ = undef;
        my $rcopen = open my $fh, "-|", $cmd;
        if (!defined($rcopen)) {
            logprint_with_config("Starting command '$cmd' failed: $!\n", $CONFIG);
            unless ($fail_ok) {
                logprint_with_config("Aborting\n", $CONFIG);
                print "See /var/log/xen-tools/".$CONFIG->{'hostname'}.".log for details\n";
                $CONFIG->{'FAIL'} = 1;
                exit 127;
            }
        }
        <$fh>;
    };

    return (trim($result));
}

=head2 setupAdminUsers (xen-shell helper)

=begin doc

  This routine is designed to ensure that any users specified with
 the --admins flag are setup as administrators of the new instance.

=end doc

=cut

sub setupAdminUsers ($)
{
    my $CONFIG = (@_);

    #
    #  If we're not root we can't modify users.
    #
    return if ( $EFFECTIVE_USER_ID != 0 );

    #
    #  If we don't have a sudoers file then we'll also ignore this.
    #
    return if ( !-e "/etc/sudoers" );

    #
    #  Find the path to the xen-login-shell
    #
    my $shell = undef;
    $shell = "/usr/bin/xen-login-shell" if ( -x "/usr/bin/xen-login-shell" );
    $shell = "/usr/local/bin/xen-login-shell"
      if ( -x "/usr/bin/local/xen-login-shell" );

    return if ( !defined($shell) );


    #
    #  For each user make sure they exist, and setup the
    # login shell for them.
    #
    foreach my $user ( split( /,/, $ENV{ 'admins' } ) )
    {

        # Strip leading and trailing whitespace.
        $user =~ s/^\s+//;
        $user =~ s/\s+$//;

        # Ignore root
        next if ( $user =~ /^root$/i );

        # Does the user exist?
        if ( getpwnam($user) )
        {

            # Change shell.
            if ($CONFIG->{ 'verbose' }) {
                logprint_with_config("Changing shell for $user: $shell\n", $CONFIG);
            }
            system( "chsh", "-s", $shell, $user );
        }
        else
        {

            # Add a new user.
            if ($CONFIG->{ 'verbose' }) {
                logprint_with_config("Adding new user: $user\n", $CONFIG);
            }
            system( "useradd", "-s", $shell, $user );
        }

        #
        #  Add the entry to /etc/sudoers.
        #
        open( SUDOERS, ">>", "/etc/sudoers" ) or
          warn "Failed to add user to sudoers file : $user - $!";
        print SUDOERS
          "$user ALL = NOPASSWD: /usr/sbin/xm, /usr/sbin/xl, /usr/bin/xen-create-image\n";
        close(SUDOERS);

    }
}


=head2 fail_with_config

=begin doc

  Properly set $CONFIG{FAIL} on die

=end doc

=cut

sub fail_with_config ($$)
{
    my ($text, $CONFIG) = (@_);

    logprint_with_config($text, $CONFIG);
    $CONFIG->{'FAIL'} = 1;
    exit 127;
}



=head2 logonly_with_config

=begin doc

  Print the given string to the logfile.

=end doc

=cut

sub logonly_with_config ($$)
{
    my ($text, $CONFIG) = (@_);

    if ( $CONFIG->{ 'hostname' } )
    {
        open( LOGFILE, '>>', '/var/log/xen-tools/'.$CONFIG->{'hostname'}.'.log' ) or
          return;
        print LOGFILE $text;
        close(LOGFILE);
    }
}


=head2 logprint_with_config

=begin doc

  Print the given string both to our screen, and to the logfile.

=end doc

=cut

sub logprint_with_config ($$)
{
    my ($text, $CONFIG) = (@_);

    print $text;
    logonly_with_config($text, $CONFIG);
}


=head1 AUTHORS

 Steve Kemp, https://steve.fi/
 Axel Beckert, https://axel.beckert.ch/
 Dmitry Nedospasov, http://www.nedos.net/
 Stéphane Jourdois

 Merged from several scripts by Axel Beckert.

=cut

return 1;
