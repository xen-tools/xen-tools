#!/usr/bin/perl -w
#
#  Test that the tls-disabling hook works.
#
# Steve
# --
# $Id: hook-tls.t,v 1.3 2006-06-24 20:18:27 steve Exp $
#

use strict;
use Test::More qw( no_plan );
use File::Temp;


testTLSDisabling( "centos4" );
testTLSDisabling( "debian" );
testTLSDisabling( "gentoo" );
testTLSDisabling( "ubuntu" );


#
#  Test that there is a hook for the given distribution, and that
# it successfully disables a faked TLS.
#
sub testTLSDisabling
{
    my ( $dist ) = ( @_ );

    #
    #  Create a temporary directory.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );

    mkdir( $dir . "/lib", 0777 );
    mkdir( $dir . "/lib/tls", 0777 );
    mkdir( $dir . "/lib/tls/foo", 0777 );

    ok( -d $dir, "Temporary directory created OK" );
    ok( -d $dir . "/lib/tls", "TLS directory OK" );
    ok( -d $dir . "/lib/tls/foo", "TLS directory is non-empty" );


    #
    # Make sure we have the distro-specific hook directory, and
    # TLS-disabling hook script.
    #
    ok( -d "hooks/$dist", "There is a hook directory for the distro $dist" );

    ok( -e "hooks/$dist/10-disable-tls", "TLS Disabling hook exists" );
    ok( -x "hooks/$dist/10-disable-tls", "TLS Disabling hook is executable" );

    #
    #  Call the hook
    #
    `hooks/$dist/10-disable-tls $dir`;

    #
    # Make sure the the TLS directory is empty
    #
    ok( ! -e "$dir/lib/tls/foo", "The fake library from /lib/tls is gone" );
    ok( -e "$dir/lib/tls.disabled/foo", "The fake library ended up in /lib/tls.disabled" );
    ok( -d "$dir/lib/tls", "There is a new /lib/tls directory" );
}
