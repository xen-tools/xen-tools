#!perl -w
#
#  Test that the /etc/inittab file is modified as we expect.
#
# Steve
# --
#

use strict;
use Test::More;
use Test::File::Contents;
use File::Temp;
use File::Copy;
use File::Path qw(make_path);

my $hook_dir = $ENV{AS_INSTALLED_TESTING} ? '/usr/share/xen-tools' : 'hooks';

foreach my $dist (qw(stretch buster bullseye bookworm sid)) {
    testHook( $dist );
}

done_testing();

sub testHook
{
    my ( $dist ) = ( @_ );
    my $ea   = 'etc/apt';
    my $easl = "$ea/sources.list";
    my $hook = "$hook_dir/" .
        (
         $ENV{AS_INSTALLED_TESTING} ?
         $dist :
         'debian'
        ) . '/20-setup-apt';

    #
    #  Create a temporary directory to use as prefix
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );
    make_path( "$dir/$ea/apt.conf.d", { chmod => 0755 });
    make_path( "$dir/bin", { chmod => 0755 });
    my $tmphook = "$dir/bin/20-setup-apt";

    #
    # Make sure that worked.
    #
    ok( -d $dir, "temporary directory created OK [$dist]" );
    ok( -d "$dir/bin",
        "bin inside temporary directory created OK [$dist]" );
    ok( -d "$dir/$ea",
        "$ea inside temporary directory created OK [$dist]" );

    # Create a copy of the 20-setup-apt hook to be able to comment out
    # the chroot + apt-get update call.
    File::Copy::cp( $hook, $tmphook );

    ok( -e "$tmphook", "hook exists in temporary directory [$dist]" );
    # File::Copy in Perl 5.10 does not copy permissions, so let's fix
    # it there and check for it elsewhere.
    if ($] < 5.011) {
        chmod(0755, $tmphook);
    } else {
        ok( -x "$tmphook", "hook is executable in temporary directory [$dist]" );
    }

    no warnings qw(qw);
    is(system(qw(sed -e s/chroot/#chroot/ -i), $tmphook) >> 8, 0,
       "chroot call in hook could be deactivated [$dist]");
    use warnings qw(qw);

    #
    # Set up some variables expected by the hook
    #
    $ENV{dist} = $dist;
    $ENV{mirror} = 'http://deb.debian.org/debian';

    #
    #  Call the hook
    #
    is(system($tmphook, $dir) >> 8, 0,
       "hook for $dist exited with zero return code");

    ok( -e "$dir/$easl", "A sources.list file has been created. [$dist]" );
    if ($dist =~ /stretch|buster/) {
        file_contents_like( "$dir/$easl", qr(\b${dist}/updates\b),
                            "sources.list contains $dist/updates");
        file_contents_unlike( "$dir/$easl", qr(\b${dist}-security\b),
                              "sources.list doesn't contain $dist-security");
    } else {
        file_contents_like( "$dir/$easl", qr(\b${dist}-security\b),
                            "sources.list contains $dist-security");
        file_contents_unlike( "$dir/$easl", qr(\b${dist}/updates\b),
                              "sources.list doesn't contain $dist/updates");
    }
}
