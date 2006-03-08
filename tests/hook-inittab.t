#!/usr/bin/perl -w
#
#  Test that the /etc/inittab file is modified as we expect.
#
# Steve
# --
# $Id: hook-inittab.t,v 1.1 2006-03-08 21:01:44 steve Exp $
#

use strict;
use Test::More qw( no_plan );
use File::Temp;
use File::Copy;


#
#  Sanity check.
#
ok( -e "/etc/inittab", "/etc/inittab exists." );


#
#  Create a temporary directory, and copy our inittab into it.
#
my $dir	= File::Temp::tempdir( CLEANUP => 1 );
mkdir( $dir . "/etc", 0777 );
File::Copy::cp( "/etc/inittab", $dir . "/etc" );

#
# Make sure that worked.
#
ok( -d $dir, "Temporary directory created OK" );
ok( -e $dir . "/etc/inittab", "/etc/inittab copied correctly." );



ok( -e "etc/hook.d/30-fix-inittab", "inittab fixing hook exists" );
ok( -x "etc/hook.d/30-fix-inittab", "inittab fixing hook is executable" );

#
#  Call the hook
#
`etc/hook.d/30-fix-inittab $dir`;

#
#  Now we read the new file, and make sure it looks like we expect.
#
open( INIT, "<", $dir . "/etc/inittab" )
  or die "Failed to open modified inittab.";
my @lines = <INIT>;
close( INIT );

#
# Test we read some lines.
#
ok( $#lines > 0, "We read the new inittab." );


#
# Now test that the lines look like they should.
#
my $count = 0;
foreach my $line ( @lines )
{
    if ( $line =~ /^([1-9])(.*) (.*)$/ )
    {
	#
	# This should be our only line:
	#
	#  1:2345:respawn:/sbin/getty 38400 console
	#
	ok( $1 eq "1", "We found the first getty line." );
	ok( $3 eq "console", "Which does use the console driver." );
    }

    if ( $line =~ /^(.).*getty/ )
    {
	$count += 1 if ( $1 ne "#" );
    }
}

ok( $count = 1, "Only found one uncommented getty line" );
