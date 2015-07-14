#!perl -w
#
#  Test that the xen-delete-image script will delete an images
# contents correctly.
#
# Steve
# --
#


use strict;
use Test::More;
use File::Temp;


#
#  Create a temporary directory.
#
my $dir            = File::Temp::tempdir( CLEANUP => 1 );
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
#  Generate a random hostname.
#
my $hostname = join ( '', map {('a'..'z')[rand 26]} 0..17 );
ok( ! -d $domains . "/" . $hostname, "The virtual hostname doesnt exist." );

#
#  Make the hostname directory
#
mkdir( $domains . "/" . $hostname, 0777 );
ok( -d $domains . "/" . $hostname, "The virtual hostname now exists." );


#
#  Create a stub disk image
#
open( IMAGE, ">", $domains . "/" . $hostname . "/" . "disk.img" )
  or warn "Failed to open disk image : $!";
print IMAGE "Test";
close( IMAGE );


#
#  Create a stub swap image
#
open( IMAGE, ">", $domains . "/" . $hostname . "/" . "swap.img" )
  or warn "Failed to open swap image : $!";
print IMAGE "Test";
close( IMAGE );


#
#  Now we have :
#
#  $dir/
#  $dir/domains/
#  $dir/domains/$hostname
#  $dir/domains/$hostname/disk.img
#  $dir/domains/$hostname/swap.img
#
#  So we need to run the deletion script and verify the images
# are removed correctly.
#
my $prefix = $ENV{AS_INSTALLED_TESTING} ? '/usr/' : 'perl -Ilib -I../lib ';
my $log = `${prefix}bin/xen-delete-image --test --verbose --dir=$dir $hostname`;
ok ( $? == 0, 'Calling xen-delete-image returned exit code 0' );
print $log;


#
#  If the deletion worked our images are gone.
#
ok( ! -e $domains . "/" . $hostname . "/" . "disk.img",
    "Disk image deleted successfully." );
ok( ! -e $domains . "/" . $hostname . "/" . "swap.img",
    "Swap image deleted successfully." );

#
#  And the hostname directory should have gone too.
#
ok( ! -d $domains . "/" . $hostname,
    "The hostname directory was removed" );

done_testing();
