#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
# $Id: hooks.t,v 1.2 2006-01-02 13:59:13 steve Exp $
#

use strict;
use Test::More qw( no_plan );

foreach my $file ( glob( "etc/xen-create-image.d/*" ) )
{
    if ( ! -d $file )
    {
	ok( -e $file, "$file" );
	ok( -x $file, " File is executable: $file" );
    }
}

