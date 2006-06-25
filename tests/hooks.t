#!/usr/bin/perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
# $Id: hooks.t,v 1.7 2006-06-25 20:02:33 steve Exp $
#

use strict;
use Test::More qw( no_plan );


#
#  Rather than having a hardwired list of distributions to test
# against we look for subdirectories beneath hooks/ and test each
# one.
#
foreach my $dir ( glob( "hooks/*" ) )
{
    next if ( $dir =~ /CVS/i );
    next if ( ! -d $dir );

    if ( $dir =~ /hooks\/(.*)/ )
    {
        my $dist = $1;
        testDistroHooks( $dist );
    }
}



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

