#!/usr/bin/perl -w
#
#  Test that the Xen configuration file works as expected.
#
# Steve
# --
# $Id: hook-cfg.t,v 1.2 2006-05-26 15:04:15 steve Exp $
#

use strict;
use Test::More qw( no_plan );
use File::Temp;


#
# Preserve original environment.
#
my %SAFE_ENV = %ENV;


#
#  Create a temporary directory.
#
my $dir	= File::Temp::tempdir( CLEANUP => 1 );


ok( -d $dir, "Temporary directory created OK: $dir" );



ok( -e "etc/hook.d/95-create-cfg", "Xen cfg hook exists" );
ok( -x "etc/hook.d/95-create-cfg", "Xen cfg hook is executable" );

#
#  Call the hook one for static, and once for dynamic.
#
callHook( 1 );
callHook( 0 );



#
#  Call the Xen .cfg file creation hook and make sure the results
# match what we expect.
#
sub callHook
{
    my ( $dhcp ) = ( @_ );

    #
    # Reset environment.
    #
    foreach my $key ( keys %SAFE_ENV )
    {
	$ENV{$key} = $SAFE_ENV{$key};
    }

    #
    #  Make sure we're testing.
    #
    $ENV{'testing'}	= 1;
    $ENV{'testing_dir'}	= $dir;

    $ENV{'kernel'}	= '/vmlinuz.img';
    $ENV{'memory'}	= '128Mb';
    $ENV{'hostname'}	= 'test.my.flat';

    #
    # DHCP vs. Static.
    #
    $ENV{'ip'}	 = '';
    $ENV{'dhcp'} = '';

    $ENV{'ip' }		= '192.168.1.200' if !$dhcp;
    $ENV{'dhcp'}	= 1 if $dhcp;

    #
    # Call the hook
    #
    `etc/hook.d/95-create-cfg $dir`;

    #
    # Test the results.
    #
    open( OUTPUT, "<", $dir . "/test.my.flat.cfg" )
      or die "Failed to open output";
    my @lines = <OUTPUT>;
    close( OUTPUT );

    my $kernel = grep( /kernel.*vmlinuz/, @lines );
    ok( $kernel, "Found the kernel line" );

    my $memory = grep( /memory.*128Mb/, @lines );
    ok( $memory, "Found the memory line" );


    my $ip	= grep( /ip[ \t]*=/, @lines );
    my $dynamic	= grep( /dhcp[ \t]*=/, @lines );

    if ( $dhcp )
    {
	ok( $ip == 0, "DHCP - didn't find IP address." );
	ok( $dynamic, "DHCP - found DHCP." );
    }
    if ( ! $dhcp )
    {
	ok( $dynamic == 0, "Static - didn't find DHCP address." );
	ok( $ip, "Static - found IP address." );
    }

    #
    # Cleanup
    #
    unlink( $dir . "/test.my.flat.cfg" );

}


