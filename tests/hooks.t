#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
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

