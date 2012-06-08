#!/usr/bin/perl -I../lib -I./lib

use strict;
use warnings;
use Test::More tests => 1, skip_all => 'Xen::Tools::Log is not used for now';
use File::Temp;

use Xen::Tools::Log;

my $dir = File::Temp::tempdir( CLEANUP => 1 );

my $xtl = Xen::Tools::Log->new( hostname => 'xen-tools-log-test',
                                logpath  => $dir );

ok( $xtl->isa('Xen::Tools::Log') );
