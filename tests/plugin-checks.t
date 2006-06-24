#!/usr/bin/perl -w
#
#  Test that the plugins each refer to environmental variables,
# not the perl config hash.
#
# Steve
# --
# $Id: plugin-checks.t,v 1.6 2006-06-24 20:19:17 steve Exp $
#


use strict;
use Test::More qw( no_plan );


testPlugins( "centos4" );
testPlugins( "debian" );
testPlugins( "gentoo" );
testPlugins( "ubuntu" );


sub testPlugins
{
    my ( $dist ) = ( @_ );

    #
    # Make sure there is a hook directory for the named distro
    #
    ok( -d "hooks/$dist/", "There is a hook directory for the distro $dist" );

    #
    # Make sure the plugins are OK.
    #
    foreach my $file ( glob( "hooks/$dist/*" ) )
    {
        ok( -e $file, "$file" );

        if ( -f $file )
        {
            ok( -x $file, "File is executable" );

            #
            #  Make sure the file is OK
            #
            my $result = testFile( $file );
            is( $result, 0, " File contains no mention of the config hash" );

        }
    }

}



#
#  Test that the named file contains no mention of '$CONFIG{'xx'};'
#
sub testFile
{
    my ( $file ) = ( @_ );

    open( FILY, "<", $file ) or die "Failed to open $file - $!";

    foreach my $line ( <FILY> )
    {
        if ( $line =~ /\$CONFIG{[ \t'"]+(.*)[ \t'"]+}/ )
        {
            close( FILY );
            return $line;
        }
    }
    close( FILY );

    #
    # Success
    #
    return 0;
}

