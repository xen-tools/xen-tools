#!/usr/bin/perl -w
#
#  Test that every perl script accepts and processes each of the options
# documented in its POD.
#
#  Cute test :)
#
# Steve
# --
# $Id: getopt.t,v 1.1 2006-06-22 14:52:58 steve Exp $


use strict;
use File::Find;
use Test::More qw( no_plan );


#
#  Test each file
#
foreach my $file ( sort( glob "./bin/*-*" ) )
{
    testFile( $file );
}


#
#  Check a file.
#
#  If this is a perl file then call "perl -c $name", otherwise
# return
#
sub testFile
{
    my ($file ) = (@_);
    is( -e $file, 1, "File exists: $file" );
    is( -x $file, 1, "File is executable" );

    #
    #  Run the file with "--help" and capture the output.
    #
    my $output = `$file --help`;

    #
    #  Parse out the options we accept
    #
    my @documented = ();

    foreach my $line ( split( /\n/, $output ) )
    {
        if ( $line =~ /[ \t]*--([a-z-]+)/ )
        {
            push @documented, $1;
        }
    }

    #
    #  Test we got some options
    #
    ok( $#documented > 1, "We found some options documented." );

    #
    #  Now read the input file.
    #
    open( IN, "<", $file ) or die "Failed to open file for reading $file - $!";
    my @LINES = <IN>;
    close( IN );

    #
    #  Options accepted
    #
    my %accepted;

    #
    #  Do minimal parsing to find the options we process with
    # Getopt::Long;
    #
    my $complete = join( "\n", @LINES );
    if ( $complete =~ /GetOptions\(([^\)]+)\)/mi )
    {
        my $opt = $1;

        #
        #  Process each one.
        #
        foreach my $o ( split( /\n/, $opt ) )
        {
            #
            #  Strip trailing comments.
            #
            if ( $o =~ /([^#]+)#/ )
            {
                $o = $1;
            }

            #
            #  Remove "" from around it.
            #
            if ( $o =~ /"([^"]+)"/ )
            {
                $o = $1;
            }

            #
            #  Discard anything after "=", or " "
            #
            if ( $o =~ /(.*)[ \t=]+(.*)/ )
            {
                $o = $1;
            }

            #
            #  Now avoid blank lines.
            #
            next if ( $o =~ /^[ \t]*$/ );


            #
            #  Phew.  Now we're done.
            #
            $accepted{$o} = 1;
        }
    }

    #
    #  Now we want to find an option that is not documented.
    #
    foreach my $argument ( @documented )
    {
        is( $accepted{$argument}, 1, "Option '--$argument' accepted" );
    }
}
