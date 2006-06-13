#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
# $Id: hooks.t,v 1.5 2006-06-13 13:26:00 steve Exp $
#

use strict;
use Test::More qw( no_plan );


testDistroHooks( "debian" );
testDistroHooks( "centos4" );


sub testDistroHooks
{
    my ( $dist ) = ( @_ );

    #
    # Make sure we have a distro-specific hook directory.
    #
    ok( -d "hooks/$dist", "There is a hook directory for distro $dist" );

    #
    # Now make sure we just have files, and that they are executable.
    #
    foreach my $file ( glob( "hooks/$dist/*" ) )
    {
        if ( ! -d $file )
        {
            ok( -e $file, "$file" );
            ok( -x $file, " File is executable: $file" );
        }
    }
}

