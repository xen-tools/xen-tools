#!perl -w
#
#  Test that our policy-rc.d file is created and removed as we expect in our hooks.
#
# Steve
# --
#


use strict;
use Test::More;
use File::Temp;




#
#  Rather than having a hardwired list of distributions to test
# against we look for subdirectories beneath hooks/ and test each
# one.
#

my $hook_dir = $ENV{AS_INSTALLED_TESTING} ? '/usr/share/xen-tools' : 'hooks';
foreach my $dir ( glob( "$hook_dir/*" ) )
{
    next if ( $dir =~ /CVS/i );
    next if ( ! -d $dir );

    if ( $dir =~ /$hook_dir\/(.*)/ )
    {
        my $dist = $1;

        maybeCallHook( $dist );
    }
}

done_testing();

#
#  If the given distribution has the following two files test them:
#
#   01-disable-daemons
#   99-enable-daemons
#
sub maybeCallHook
{
    my( $dist ) = (@_);

    #
    #  Do the two files exist?
    #
    foreach my $file ( qw/ 01-disable-daemons 99-enable-daemons / )
    {
        return if ( ! -e "$hook_dir/$dist/$file" );
    }

    #
    #  Call the test on the given distribution
    #
    testHook( $dist );
}



#
#  Test that the two hooks work.
#
sub testHook
{
    my ( $dist ) = ( @_ );

    #
    #  Output
    #
    ok( $dist, "Testing: $dist" );

    #
    #  Create a temporary directory.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );

    #
    #  Test we got a directory and there is no /usr/sbin there.
    #
    ok(   -d $dir, "Temporary directory created OK" );
    ok( ! -d $dir . "/usr/sbin", "There is no /usr/sbin directory there. yet" );;


    #
    #  Call the first hook
    #
    `$hook_dir/$dist/01-disable-daemons $dir`;

    #
    #  Now /usr/sbin should exist.
    #
    ok( -d $dir . "/usr/sbin", "The /usr/sbin directory was created" );
    ok( -x $dir . "/usr/sbin/policy-rc.d", "The policy-rc.d file was created" );

    #
    #  Now call the second hook
    #
    `$hook_dir/$dist/99-enable-daemons $dir`;

    ok( ! -x $dir . "/usr/sbin/policy-rc.d", "The policy-rc.d file was correctly removed" );
}

