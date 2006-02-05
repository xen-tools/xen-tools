#!/usr/bin/perl -w
#
#  Test that each of the role scripts is executable.
#
# Steve
# --
# $Id: roles.t,v 1.1 2006-02-05 18:14:55 steve Exp $
#

use strict;
use Test::More qw( no_plan );

foreach my $file ( glob( "etc/role.d/*" ) )
{
    if ( ! -d $file )
    {
	ok( -e $file, "$file" );
	ok( -x $file, " File is executable: $file" );
    }
}

