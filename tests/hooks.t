#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
# $Id: hooks.t,v 1.6 2006-06-24 20:18:27 steve Exp $
#

use strict;
use Test::More qw( no_plan );


testDistroHooks( "centos4" );
testDistroHooks( "debian" );
testDistroHooks( "gentoo" );
testDistroHooks( "ubuntu" );


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

