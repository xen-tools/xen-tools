#!/usr/bin/perl -w
#
#  Test that the plugins each refer to environmental variables,
# not the perl config hash.
#
# Steve
# --
# $Id: plugin-checks.t,v 1.2 2006-01-07 23:23:12 steve Exp $
#


use strict;
use Test::More qw( no_plan );


foreach my $file ( glob( "etc/hook.d/*" ) )
{
    ok( -e $file, "$file" );

    if ( -f $file )
    {
	#
	#  Make sure the file is OK
	#
	my $result = testFile( $file );
	is( $result, 0, " File contains no mention of the config hash" );
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

