#!/usr/bin/perl -w
#
#  Test that the xen-list-images script can detete two "fake"
# images we construct manually.
#
#
# Steve
# --
# $Id: xen-lists-images.t,v 1.2 2006-01-07 17:39:34 steve Exp $
#


use strict;
use Test::More qw( no_plan );
use File::Temp;


#
#  Create a temporary directory.
#
my $dir	    = File::Temp::tempdir( CLEANUP => 1 );
my $domains = $dir . "/domains";

#
#  Test that we can make the directory.
#
ok ( -d $dir, "The temporary directory was created: $dir" );

#
#  Create the domains directory.
#
ok ( ! -d $domains, "The temp directory doesn't have a domains directory." );
mkdir( $domains, 0777 );
ok ( -d $domains, "The temp directory now has a domains directory." );


#
#  Generate two random hostnames.
#
my $one = join ( '', map {('a'..'z')[rand 26]} 0..17 );
ok( ! -d $domains . "/" . $one, "The first virtual hostname doesnt exist." );
mkdir( $domains . "/" . $one, 0777 );
ok( -d $domains . "/" . $one, "The first virtual hostname now exists." );

my $two = join ( '', map {('a'..'z')[rand 26]} 0..17 );
ok( ! -d $domains . "/" . $two, "The second virtual hostname doesnt exist." );
mkdir( $domains . "/" . $two, 0777 );
ok( -d $domains . "/" . $two, "The second virtual hostname now exists." );


#
#  Create a stub disk image
#
createImage( $domains . "/" . $one );
createImage( $domains . "/" . $two );


#
#  Now we have :
#
#  $dir/
#  $dir/domains/
#  $dir/domains/$one
#  $dir/domains/$one/disk.img
#  $dir/domains/$one/swap.img
#  $dir/domains/$two
#  $dir/domains/$two/disk.img
#  $dir/domains/$two/swap.img
# 
#  So we need to run the listing script and verify that two images
# are detected.
#
#

my $output = `./xen-list-images --dir=$dir --test`;

foreach my $line ( split( /\n/, $output ) )
{
    if ( $line =~ /Image: $one/ )
    {
	ok( 1, "First image found" );
    }
    elsif ( $line =~ /Image: $two/ )
    {
	ok( 1, "Second image found" );
    }
    else
    {
	ok( 0, "Unexpected output : $line " );
    }
}




#
#  Create a disk + swap image in the given directory.
#
sub createImage
{
    my ($dir) = ( @_ );

    open( IMAGE, ">", $dir . "/" . "disk.img" )
      or warn "Failed to open disk image : $!";
    print IMAGE "Test";
    close( IMAGE );
    ok( -e $dir . "/disk.img", "Disk image created properly" );


    open( SWAP, ">", $dir . "/" . "swap.img" )
      or warn "Failed to open disk image : $!";
    print SWAP "Test";
    close( SWAP );
    ok( -e $dir . "/swap.img", "Swap image created properly" );
}

