# -*- perl -*

package Xen::Tools::Common;

=head1 NAME

Xen::Tools::Common - Common funtions used in xen-tools' Perl scripts

=head1 SYNOPSIS

 use Xen::Tools::Common;

=cut

use warnings;
use strict;

use Exporter 'import';
use vars qw(@EXPORT_OK @EXPORT);

use English;

@EXPORT = qw(readConfigurationFile xenRunning runCommand setupAdminUsers
             logprint logonly fail);

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

    open( FILE, "<", $file ) or fail("Cannot read file '$file' - $!");

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
        if ( $line =~ /(.*)\#(.*)/ )
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

sub xenRunning ($)
{
    my ($hostname) = (@_);

    my $running = 0;

    open( CMD, "xm list $hostname 2>/dev/null |" ) or
      die "Failed to run 'xm list $hostname'";
    while (<CMD>)
    {
        my $line = $_;
        $running = 1 if ( $line =~ /\Q$hostname\E/ );
    }
    close(CMD);

    return ($running);
}

=head2 runCommand

=begin doc

  A utility method to run a system command.  We will capture the return
 value and exit if the command files.

  When running verbosely we will also display any command output once
 it has finished.

=end doc

=cut

sub runCommand ($$)
{
    my ($cmd, $CONFIG) = (@_);

    #
    #  Set a local if we don't have one.
    #
    $ENV{ 'LC_ALL' } = "C" unless ( $ENV{ 'LC_ALL' } );

    #
    #  Header.
    #
    $CONFIG->{ 'verbose' } && print "Executing : $cmd\n";

    #
    #  Copy stderr to stdout, so we can see it, and make sure we log it.
    #
    $cmd .= " 2>&1";

    #
    #  Run it.
    #
    my $rcopen = open(CMD, '-|', $cmd);
    if (!defined($rcopen)) {
        logprint("Starting command '$cmd' failed: $!\n");
        logprint("Aborting\n");
        print "See /var/log/xen-tools/".$CONFIG->{'hostname'}.".log for details\n";
        $CONFIG->{'FAIL'} = 1;
        exit 127;
    }

    while (my $line = <CMD>) {
        if ($CONFIG->{ 'verbose' }) {
            logprint $line;
        } else {
            logonly $line;
        }
    }

    my $rcclose = close(CMD);

    $CONFIG->{ 'verbose' } && print "Finished : $cmd\n";

    if (!$rcclose)
    {
        logprint("Running command '$cmd' failed with exit code $?.\n");
        logprint("Aborting\n");
        print "See /var/log/xen-tools/".$CONFIG->{'hostname'}.".log for details\n";
        $CONFIG->{'FAIL'} = 1;
        exit 127;
    }

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
            $CONFIG->{ 'verbose' } && print "Changing shell for $user: $shell\n";
            system( "chsh", "-s", $shell, $user );
        }
        else
        {

            # Add a new user.
            $CONFIG->{ 'verbose' } && print "Adding new user: $user\n";
            system( "useradd", "-s", $shell, $user );
        }

        #
        #  Add the entry to /etc/sudoers.
        #
        open( SUDOERS, ">>", "/etc/sudoers" ) or
          warn "Failed to add user to sudoers file : $user - $!";
        print SUDOERS
          "$user ALL = NOPASSWD: /usr/sbin/xm, /usr/bin/xen-create-image\n";
        close(SUDOERS);

    }
}


=begin doc

  Properly set $FAIL on die

=end doc

=cut

sub fail
{
    logprint(@_);
    $FAIL = 1;
    exit 127;
}



=begin doc

  Print the given string to the logfile.

=end doc

=cut

sub logonly
{
    my ($text) = (@_);

    if ( $CONFIG{ 'hostname' } )
    {
        open( LOGFILE, ">>", "/var/log/xen-tools/$CONFIG{'hostname'}.log" ) or
          return;
        print LOGFILE $text;
        close(LOGFILE);
    }
}


=begin doc

  Print the given string both to our screen, and to the logfile.

=end doc

=cut

sub logprint
{
    my ($text) = (@_);

    print $text;
    logonly($text);
}


=head1 AUTHORS

 Steve Kemp, http://www.steve.org.uk/
 Axel Beckert, http://noone.org/abe/
 Dmitry Nedospasov, http://nedos.net/
 Stéphane Jourdois

 Merged from several scripts by Axel Beckert.

=cut

return 1;
