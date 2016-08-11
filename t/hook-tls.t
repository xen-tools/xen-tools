#!perl
#
#  Test that the tls-disabling hook works.
#
# Steve
# --
#

use Config qw(config_vars);
use Test::More;
use File::Temp;


if ( $Config::Config{archname} =~ /64/ )
{
    plan skip_all => "This test will fail upon 64 bit systems" ;
}

#
#  Rather than having a hardwired list of distributions to test
# against we look for subdirectories beneath hooks/ and test each
# one.
#
my $hook_dir = $ENV{AS_INSTALLED_TESTING} ? '/usr/share/xen-tools' : 'hooks';
foreach my $dir ( glob( "$hook_dir/*" ) )
{
    next if ( $dir =~ /CVS|common/i );
    next if ( ! -d $dir );

    if ( $dir =~ /$hook_dir\/(.*)/ )
    {
        my $dist = $1;

        testTLSDisabling( $dist ) if -e "$hook_dir/$dist/10-disable-tls";
    }
}

done_testing();


#
#  Test that there is a hook for the given distribution, and that
# it successfully disables a faked TLS.
#
sub testTLSDisabling
{
    my ( $dist ) = ( @_ );

    #
    #  Create a temporary directory.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );

    mkdir( $dir . "/lib", 0777 );
    mkdir( $dir . "/lib/tls", 0777 );
    mkdir( $dir . "/lib/tls/foo", 0777 );

    ok( -d $dir, "Temporary directory created OK" );
    ok( -d $dir . "/lib/tls", "TLS directory OK" );
    ok( -d $dir . "/lib/tls/foo", "TLS directory is non-empty" );


    #
    # Make sure we have the distro-specific hook directory, and
    # TLS-disabling hook script.
    #
    ok( -d "$hook_dir/$dist", "There is a hook directory for the distro $dist" );

    ok( -e "$hook_dir/$dist/10-disable-tls", "TLS Disabling hook exists ($dist)" );
    ok( -x "$hook_dir/$dist/10-disable-tls", "TLS Disabling hook is executable ($dist)" );

    #
    #  Call the hook
    #
    `$hook_dir/$dist/10-disable-tls $dir`;

    #
    # Make sure the TLS directory is empty
    #
    ok( ! -e "$dir/lib/tls/foo", "The fake library from /lib/tls is gone ($dist)" );
    ok( -e "$dir/lib/tls.disabled/foo", "The fake library ended up in /lib/tls.disabled ($dist)" );
    ok( -d "$dir/lib/tls", "There is a new /lib/tls directory ($dist)" );
}
