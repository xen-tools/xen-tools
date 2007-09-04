package Xen::Tools;

use warnings;
use strict;
use Moose;

use Xen::Tools::Log;

=head1 NAME

Xen::Tools - Build Xen domains with Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 my $xt = Xen::Tools->new();

=head1 FUNCTIONS

=head2 new

  Instantiate the object.

=cut

override 'new' => sub {
  my $class = shift;

  # Initialize the base class
  my $self = $class->super(@_);

  $self->{_xtl} = Xen::Tools::Log->new( hostname => $self->hostname,
                                        logpath  => $self->logpath,
                                      );

  $self->_checkSystem();

  return $self;
};

=head2 meta

  This is a method which provides access to the current class's meta-
  class.  Inherited from Moose.

=cut

=head2 log

  This method sends a log message to the current object's logging
  mechanism

=cut

sub log {
  my $self = shift;

  $self->{_xtl}->print(@_);
}

=head2 hostname

 Attribute which indicates the domain's hostname

=cut

has 'hostname' => ( is => 'ro', isa => 'Str', required => 1 );

=head2 logpath

 Attribute which indicates the log directory.  Defaults to /var/log/xen-tools

=cut

has 'logpath'  => ( is      => 'ro',
                    isa     => 'Str',
                    default => '/var/log/xen-tools'
                    );

=begin doc

_findBinary

  Find the location of the specified binary on the curent user's PATH.

  Return undef if the named binary isn't found.

=end doc

=cut

sub _findBinary {
  my $self = shift;
    my( $bin ) = (@_);

    # strip any path which might be present.
    $bin  = $2 if ( $bin  =~ /(.*)[\/\\](.*)/ );

    foreach my $entry ( split( /:/, $ENV{'PATH'} ) )
    {
        # guess of location.
        my $guess = $entry . "/" . $bin;

        # return it if it exists and is executable
        return $guess if ( -e $guess && -x $guess );
    }

    return;
}

=begin doc

_checkSystem

  Test that this system is fully setup for the new xen-create-image
 script.

  This means that the the companion scripts xt-* are present on the
 host and executable.

=end doc

=cut

sub _checkSystem {
  my $self = shift;
    my @required = qw ( / xt-customize-image
                          xt-install-image
                          xt-create-xen-config / );

    foreach my $bin ( @required )
    {
        if ( ! defined( $self->_findBinary( $bin ) ) )
        {
            $self->log("The script '$bin' was not found.\n",
                       "Aborting\n\n"
                      );
            exit;
        }
    }

    #
    #  Make sure that we have Text::Template installed - this
    # will be used by `xt-create-xen-config` and if that fails then
    # running is pointless.
    #
    my $test = "use Text::Template";
    eval( $test );
    if ( ( $@ ) && ( ! $self->{_force} ) )
    {
        print <<E_O_ERROR;

  Aborting:  The Text::Template perl module isn't installed or available.

  Specify '--force' to skip this check and continue regardless.

E_O_ERROR
        exit;
    }


    #
    #  Make sure that xen-shell is installed if we've got an --admin
    # flag specified
    #
    if ( $self->{_admins} )
    {
        my $shell = undef;
        $shell = "/usr/bin/xen-login-shell" if ( -x "/usr/bin/xen-login-shell" );
        $shell = "/usr/local/bin/xen-login-shell" if ( -x "/usr/bin/local/xen-login-shell" );

        if ( !defined( $shell ) )
        {
            print <<EOF;

  You've specified administrator accounts for use with the xen-shell,
 however the xen-shell doesn't appear to be installed.

  Aborting.
EOF
            exit;
        }
    }


    #
    #  Test the system has a valid (network-script) + (vif-script) setup.
    #
    return $self->_testXenConfig();
}

=begin doc

  Test that the current Xen host has a valid network configuration,
 this is designed to help newcomers to Xen.

=end doc

=cut

sub _testXenConfig {
  my $self = shift;
    # wierdness.
    return if ( ! -d "/etc/xen" );

    #
    #  Temporary hash.
    #
    my %cfg;

    #
    # Read the configuration file.
    #
    open( my $config_fh, q{<}, '/etc/xen/xend-config.sxp' )
      or die "Failed to read /etc/xen/xend-config.sxp: $!";
    while( <$config_fh> )
    {
        next if ( ! $_ || !length( $_ ) );

        # vif
        if ( $_ =~ /^\(vif-script ([^)]+)/ )
        {
            $cfg{'vif-script'} = $1;
        }

        # network
        if ( $_ =~ /^\(network-script ([^)]+)/ )
        {
            $cfg{'network-script'} = $1;
        }
    }
    close( $config_fh );

    if ( !defined( $cfg{'network-script'} ) ||
         !defined( $cfg{'vif-script'} ) )
    {
        print <<EOF;

WARNING
-------

  You appear to have a missing vif-script, or network-script, in the
 Xen configuration file /etc/xen/xend-config.sxp.

  Please fix this and restart Xend, or your guests will not be able
 to use any networking!

EOF
    }
    else
    {
        if ( ( $cfg{'network-script'} =~ /dummy/i ) ||
             ( $cfg{'vif-script'}     =~ /dummy/i ) )
        {

            print <<EOF;
WARNING
-------

  You appear to have a "dummy" vif-script, or network-script, setting
 in the Xen configuration file /etc/xen/xend-config.sxp.

  Please fix this and restart Xend, or your guests will not be able to
 use any networking!

EOF
        }
    }
    return 1;
}


=head1 AUTHOR

C.J. Adams-Collier, C<< <cjac at colliertech.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xen-tools at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Xen-Tools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Xen::Tools


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Xen-Tools>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Xen-Tools>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Xen-Tools>

=item * Search CPAN

L<http://search.cpan.org/dist/Xen-Tools>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2007 C.J. Adams-Collier, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Xen::Tools
