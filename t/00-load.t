#!/usr/bin/perl -I../lib -I./lib

use Test::More tests => 2;

BEGIN {
    use_ok( 'Xen::Tools' );
    use_ok( 'Xen::Tools::Log' );
}

diag( "Testing Xen::Tools $Xen::Tools::VERSION, Perl $], $^X" );
