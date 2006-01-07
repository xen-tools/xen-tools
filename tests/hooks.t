#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
# $Id: hooks.t,v 1.3 2006-01-07 23:23:12 steve Exp $
#

use strict;
use Test::More qw( no_plan );

foreach my $file ( glob( "etc/hook.d/*" ) )
{
    if ( ! -d $file )
    {
	ok( -e $file, "$file" );
	ok( -x $file, " File is executable: $file" );
    }
}

