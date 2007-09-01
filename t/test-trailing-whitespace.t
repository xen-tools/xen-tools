#!/usr/bin/perl -w
#
#  Test that every script in ./bin/ has no trailing whitespace.
#
# Steve
# --
# $Id: test-trailing-whitespace.t,v 1.1 2007-09-01 19:23:10 steve Exp $


use strict;
use File::Find;
use Test::More qw( no_plan );


#
#   Find our bin/ directory.
#
my $dir = undef;

$dir = "./bin/"  if ( -d "./bin/" );
$dir = "../bin/" if ( -d "../bin/" );

plan skip_all => "No bin directory found" if (!defined( $dir ) );


#
#  Process each file.
#
foreach my $file (sort( glob ( $dir . "*" ) ) )
{
    # skip backups, and directories.
    next if ( $file =~ /~$/ );
    next if ( -d $file );

    ok( -e $file, "Found file : $file" );

    checkFile( $file );
}


#
#  Check a file.
#
#
sub checkFile
{
    my( $file ) =  (@_);

    my $trailing = 0;

    # Read the file.
    open( INPUT, "<", $file );
    foreach my $line ( <INPUT> )
    {
        $trailing = 1 if ( $line =~ /^(.*)[ \t]+$/ )
    }
    close( INPUT );

    is( $trailing, 0, "File has no trailing whitespace" );
}

