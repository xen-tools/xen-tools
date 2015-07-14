#!perl -w
#
#  Test that all the hook files we install are executable.
#
# Steve
# --
#

use strict;
use Test::More;


#
#  Rather than having a hardwired list of distributions to test
# against we look for subdirectories beneath hooks/ and test each
# one.
#
my $hook_dir = $ENV{AS_INSTALLED_TESTING} ? '/usr/share/xen-tools' : 'hooks';
foreach my $dir ( glob( "$hook_dir/*" ) )
{
    next if ( $dir =~ /CVS/i );
    next if ( $dir =~ /common/i );
    next if ( ! -d $dir );

    if ( $dir =~ /$hook_dir\/(.*)/ )
    {
        my $dist = $1;
        testDistroHooks( $dist );
    }
}

done_testing();

sub testDistroHooks
{
    my ( $dist ) = ( @_ );

    #
    # Make sure we have a distro-specific hook directory.
    #
    ok( -d "$hook_dir/$dist", "There is a hook directory for distro $dist" );

    #
    # Now make sure we just have files, and that they are executable.
    #
    foreach my $file ( glob( "$hook_dir/$dist/*" ) )
    {
        if ( ! -d $file )
        {
            ok( -e $file, "$file" );
            ok( -x $file, " File is executable: $file" );
        }
    }
}

