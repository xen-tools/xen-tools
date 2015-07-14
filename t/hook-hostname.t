#!perl -w
#
#  Test that we get an /etc/hosts etc file created when DHCP is used.
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
    next if ( $dir =~ /common/i );
    next if ( ! -d $dir );

    if ( $dir =~ /$hook_dir\/(.*)/ )
    {
        my $dist = $1;

        testHostCreation( $dist ) unless ( $dist =~ /fedora/i );
    }
}

done_testing();


#
#  Test that the creation succeeds.
#
sub testHostCreation
{
    my ( $dist ) = ( @_ );

    #
    #  Setup the environment.
    #
    $ENV{'hostname'} = "steve";
    $ENV{'dhcp'}     = 1;

    #
    #  Create a temporary directory.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );
    mkdir( $dir . "/etc", 0777 );

    #
    # Gentoo
    #
    if ( $dist =~ /gentoo/i )
    {
        mkdir( $dir . "/etc/conf.d", 0777 );
    }

    ok( -d $dir, "Temporary directory created OK" );
    ok( -d $dir . "/etc/conf.d" , "Temporary directory created OK" ) if ( $dist =~ /gentoo/i );

    #
    #  Make sure there are no files.
    #
    ok( -d $dir . "/etc/", "Temporary directory created OK" );
    ok( ! -e $dir . "/etc/hosts", " There is no hosts file present" );
    ok( ! -e $dir . "/etc/mailname", " There is no mailname file present" );
    ok( ! -e $dir . "/etc/hostname", " There is no hostname file present" );

    #
    # Make sure we have the distro-specific hook directory, and
    # TLS-disabling hook script.
    #
    ok( -d "$hook_dir/$dist", "There is a hook directory for the distro $dist" );

    ok( -e "$hook_dir/$dist/50-setup-hostname", "There is a hook for setting up hostname stuff." );

    #
    #  Call the hook
    #
    `$hook_dir/$dist/50-setup-hostname $dir`;

    ok( -e $dir . "/etc/hosts", " There is now a hosts file present" );

    #
    #  These files are not used in Gentoo
    #
    if ( $dist =~ /gentoo/i )
    {
        ok( -e $dir . "/etc/conf.d/domainname", " There is now a domainname file present" );
        ok( -e $dir . "/etc/conf.d/hostname", " There is now a hostname file present" );

    }
    else
    {
        ok( -e $dir . "/etc/mailname", " There is now a mailname file present" );
        ok( -e $dir . "/etc/hostname", " There is now a hostname file present" );
    }
}

