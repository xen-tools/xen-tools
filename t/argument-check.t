#!/usr/bin/perl -w
#
#  Test that the arguments in etc/xen-tools.conf match those used in
# xen-create-image.
#
# Steve
# --
#

use strict;
use Test::More qw( no_plan );

#
#  Open and parse the xen-tools.conf configuration file.
#
my %OPTIONS;
%OPTIONS    = parseConfigFile( "etc/xen-tools.conf" );

#
#  Test we got something back.
#
ok(  %OPTIONS, "Options successfully parsed" );


#
#  Now open and read the file "xen-create-image"
#
my @lines = readFile( "bin/xen-create-image" );
ok ( @lines, "We read the 'xen-create-image' script" );


#
#  For each option we found we want to make sure it is
# contained in the script, via the documentation.
#
foreach my $key ( sort keys %OPTIONS )
{
    my $found = 0;

    foreach my $line ( @lines )
    {
        if ( $line =~ /--$key/ )
        {
            $found = 1;
        }
    }

    next if ( $key =~ /mirror_/i );
    next if ( $key =~ /_options/i );
    next if ( $key =~ /(serial_device|disk_device)/i );

    is( $found, 1 , " Found documentation for '$key'" );
}




=head2 parseConfigFile

  Parse the 'key=value' configuration file passed to us, and
 return a hash of the reults.

=cut

sub parseConfigFile
{
    my ($file) = ( @_ );

    #
    # Options we read
    #
    my %CONFIG;

    open( FILE, "<", $file ) or die "Cannot read file '$file' - $!";

    my $line       = ""; 

    while (defined($line = <FILE>) )
    {
        chomp $line;
        if ($line =~ s/\\$//)
        {
            $line .= <FILE>;
            redo unless eof(FILE);
        }

        # Skip blank lines
        next if ( length( $line ) < 1 );

        # skip false positive
        next if ( $line =~ /Otherwise/ );

        # Find variable settings
        if ( $line =~ /([^=]+)=([^\n]+)/ )
        {
            my $key = $1;
            my $val = $2;

            if ( $key =~ /([ \t#]*)(.*)/ )
            {
                $key = $2;
            }


            # Strip leading and trailing whitespace.
            $key =~ s/^\s+//;
            $key =~ s/\s+$//;
            $val =~ s/^\s+//;
            $val =~ s/\s+$//;
            
            next if ( $key =~ /--/ );

            # Store value.
            $CONFIG{ $key } = $val;
        }
    }

    close( FILE );

    return( %CONFIG );
}




=head2 readFile

  Read a named file and return an array of its contents.

=cut

sub readFile
{
    my ($file) = ( @_ );

    open( FILE, "<", $file ) or die "Cannot read file '$file' - $!";
    my @LINES = <FILE>;
    close( FILE );

    return( @LINES );
}
