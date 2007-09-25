package Xen::Tools::Log;

use warnings;
use strict;
use Moose;
use File::Spec;
use POSIX; # strftime
use Carp;

=head1 NAME

Xen::Tools::Log - Log Xen::Tools events

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Mostly internal to Xen::Tools.  Use this to create a logging mechanism.

 my $xtl = Xen::Tools::Log->new( hostname => 'firewall' );

 $xtl->print("Yay for logging.");

=head1 FUNCTIONS

=head2 new

 Create the log object

=cut

=head2 print

  Print the given string both to our screen, and to the logfile.

=cut

sub print {
  my $self = shift;

  $self->print_screen( @_ );
  $self->print_log( @_ );
}

=head2 print_screen

  Print the given string to our screen

=cut

sub print_screen {
  my $self = shift;

  print map { "$_\n" } @_;
}

=head2 print_log

  Print the given string to the logfile.

=cut

sub print_log {
  my $self = shift;

  # Create an RFC 822 conformant date string
  my $date = strftime( "%a, %d  %b  %Y  %H:%M:%S  %z", localtime );
  my $fh = $self->log_fh();
  print $fh ( map { "$date - $_" } @_ );
}

=head2 hostname

  Attribute storing the hostname this log describes

=cut

has 'hostname' => ( is => 'rw', isa => 'Str', required => 1 );

=head2 logpath

  Attribute storing the directory in which the log file resides

=cut

has 'logpath'  => ( is      => 'rw',
                    isa     => 'Str',
                    default => '/var/log/xen-tools'
                  );

=head2 log_fh

  FileHandle attribute storing the filehandle of the log

=cut

has 'log_fh'   => ( is      => 'ro',
                    isa     => 'FileHandle',
                    lazy    => 1,
                    default => \&_init_fh,
                  );

=head2 clean_up

  Boolean attribute indicating whether the log will be cleaned up when the
  logger is closed

=cut

has 'clean_up' => ( is      => 'ro',
                    isa     => 'Bool',
                    default => 0,
                  );

before 'DESTROY' => sub {
    my $self = shift;

    # Deconstructor
};

=head2 meta

  This is a method which provides access to the current class's meta-
  class.  Inherited from Moose.

=cut

=begin doc

_init_fh

  This private method initializes the logging filehandle, creating the
  containing directory if it does not exist.

=end doc

=cut

sub _init_fh {
  my $self = shift;

  my $logFile =
    File::Spec->catfile( $self->logpath(), $self->hostname() . '.log' );

  system( 'mkdir -p', $self->logpath() ) unless -d $self->logpath();

  carp "Couldn't create log directory: $!" unless $? == 0;
  
  open( $self->{log_fh}, q{>>}, $logFile ) or
    carp "Couldn't open log file for append: $!";
};

=head1 AUTHOR

C.J. Adams-Collier, C<< <cjac at colliertech.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xen-tools-log at rt.cpan.org>, or through
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

1; # End of Xen::Tools::Log
