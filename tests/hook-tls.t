#!/usr/bin/perl -w
#
#  Test that the tls-disabling hook works.
#
# Steve
# --
# $Id: hook-tls.t,v 1.1 2006-03-08 20:08:28 steve Exp $
#

use strict;
use Test::More qw( no_plan );
use File::Temp;


#
#  Create a temporary directory.
#
my $dir	= File::Temp::tempdir( CLEANUP => 1 );

mkdir( $dir . "/lib", 0777 );
mkdir( $dir . "/lib/tls", 0777 );
mkdir( $dir . "/lib/tls/foo", 0777 );

ok( -d $dir, "Temporary directory created OK" );
ok( -d $dir . "/lib/tls", "TLS directory OK" );
ok( -d $dir . "/lib/tls/foo", "TLS directory is non-empty" );



ok( -e "etc/hook.d/10-disable-tls", "TLS Disabling hook exists" );
ok( -x "etc/hook.d/10-disable-tls", "TLS Disabling hook is executable" );

#
#  Call the hook
#
`etc/hook.d/10-disable-tls $dir`;


