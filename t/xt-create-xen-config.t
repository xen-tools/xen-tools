#!perl -w
#
#  Test that calling xt-create-xen-config with the appropriate parameters
# results in output we expect.
#
# Steve
# --
#


use strict;
use Test::More;
use File::Temp;


#
#  What we basically do here is setup a collection of environmental
# variables, and then call the script.  We then make a couple of simple
# tests against the output file which is written.
#
#

runAllTests();

# Fake File::Which to find nothing at all, i.e. no lsb_release.
$ENV{PERL5OPT} = '-It/mockup-lib'.($ENV{PERL5OPT}?" $ENV{PERL5OPT}":'');

runAllTests();

done_testing;



=head2 runAllTests

  Runs all the xt-create-xen-config test.

  The idea is to be able to run these tests multiple times under
different conditions.

=cut

sub runAllTests {
#
#  Look for mention of DHCP when setting up DHCP, this conflicts with
# a static IP address.
#
testOutputContains( "dhcp",
                    memory => 128, dhcp => 1, dir => '/tmp' );
noMentionOf( "ip=",
                    memory => 128, dhcp => 1, dir => '/tmp' );


#
#  Look for an IP address when specifying one, and make sure there
# is no mention of DHCP.
#
testOutputContains( "ip=192.168.1.1",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp' );
noMentionOf( "dhcp",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp' );

#
#  SCSI based systems:
#
testOutputContains( "xvda",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp' );
noMentionOf( "hda",
             memory => 128, ips => '192.168.1.1', dir => '/tmp' );



#
#  Boot options: pvgrub, pygrub, dkb, uefi (pvh & HVM)
#
testOutputContains( "kernel = 'my-pvh.bin'",
                    memory => 128, dhcp => 1, dir => '/tmp', pvgrub => 1, pvgrub_path => 'my-pvh.bin');
noMentionOf( "pygrub",
             memory => 128, ips => '192.168.1.1', dir => '/tmp' , pvgrub => 1, pvgrub_path => 'my-pvh.bin' );

testOutputContains( "bootloader = 'pygrub'",
                    memory => 128, dhcp => 1, dir => '/tmp', pygrub => 1);
noMentionOf( "kernel",
             memory => 128, ips => '192.168.1.1', dir => '/tmp' , pygrub => 1 );

testOutputContains( "cmdline = 'root=/dev/xvda ro console=hvc0'",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0', kernel => '/vmlinuz', serial_device => 'hvc0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap' );

testOutputContains( "firmware = 'uefi'",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => 'uefi', type => 'hvm');
testOutputContains( "firmware = 'uefi'",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => '/my-uefi', type => 'hvm');
noMentionOf( "kernel",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => '/my-uefi', type => 'hvm');
noMentionOf( "kernel",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => 'uefi', type => 'hvm');
testOutputContains( "system_firmware = '/my-uefi'",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => '/my-uefi', type => 'hvm');

testOutputContains( "kernel = 'uefi-kernel'",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => 'uefi', type => 'pvh', kernel=>"uefi-kernel");
noMentionOf( "firmware",
                    memory => 128, dhcp => 1, dir => '/tmp', firmware => 'uefi', type => 'pvh', kernel=>"uefi-kernel");


#
#  Machine types
#
testOutputContains( "type = 'pvh'",
                    memory => 128, dhcp => 1, dir => '/tmp', type => 'pvh');

testOutputContains( "type = 'pv'",
                    memory => 128, dhcp => 1, dir => '/tmp', type => 'pv');

testOutputContains( "type = 'hvm'",
                    memory => 128, dhcp => 1, dir => '/tmp', type => 'hvm');

#
#  IDE based systems
#
testOutputContains( "hda,",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp', ide => 1 );



#
#  Test memory size.
#
testOutputContains( "128",
                    memory => 128, dhcp => 1, dir => '/tmp' );
testOutputContains( "211",
                    memory => 211, dhcp => 1, dir => '/tmp' );
testOutputContains( "912",
                    memory => 912, dhcp => 1, dir => '/tmp' );


#
#  Test LVM stuff.
#
testOutputContains( "'vdev=xvdb, target=/dev/skx-vg0/swap",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap' );
testOutputContains( "'vdev=xvda, target=/dev/skx-vg0/disk",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap' );
noMentionOf( "/tmp",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap' );
noMentionOf( "domains",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap' );


#
# Test QEMU Limits.
#

testOutputContains( "'vdev=hdc, target=/dev/skx-vg0/disk3'",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0', ide => 1,
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap',
                    PARTITION3 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk3',
                    PARTITION4 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap4',
                    PARTITION5 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk5',
                    PARTITION6 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk6' );
testOutputContains( "'vdev=hdd, target=/dev/skx-vg0/swap4'",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0', ide => 1,
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap',
                    PARTITION3 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk3',
                    PARTITION4 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap4',
                    PARTITION5 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk5',
                    PARTITION6 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk6' );
testOutputContains( "'vdev=xvde, target=/dev/skx-vg0/disk5'",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0', ide => 1,
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap',
                    PARTITION3 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk3',
                    PARTITION4 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap4',
                    PARTITION5 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk5',
                    PARTITION6 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk6' );
testOutputContains( "'vdev=xvdf, target=/dev/skx-vg0/disk6'",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0', ide => 1,
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap',
                    PARTITION3 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk3',
                    PARTITION4 => 'swap:128Mb:swap:::phy:/dev/skx-vg0/swap4',
                    PARTITION5 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk5',
                    PARTITION6 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy:/dev/skx-vg0/disk6' );

#
#  Now test the loopback devices.
#
testOutputContains( "/tmp",
                    memory => 128, dhcp => 1, dir => '/tmp' );
testOutputContains( "/tmp/domains",
                    memory => 128, dhcp => 1, dir => '/tmp' );
testOutputContains( "/tmp/domains/foo.my.flat",
                    memory => 128, dhcp => 1, dir => '/tmp' );
noMentionOf( "phy:",
                    memory => 128, dhcp => 1, dir => '/tmp' );
noMentionOf( "file:",
                    memory => 128, dhcp => 1, dir => '/tmp' );
} # end of runAllTests


=head2 runCreateCommand

  Run the xt-create-xen-config command and return the output.

  This involves setting up the environment and running the command,
 once complete return the text which has been written to the xen
 configuration file.

=cut

sub runCreateCommand
{
    my ( %params ) = ( @_ );

    #
    #  Force a hostname
    #
    $params{'hostname'} = 'foo.my.flat';
    $params{'noswap'} = 1;
    if (exists $params{'PARTITION6'})
    {
        $params{'NUMPARTITIONS'} = 6;
    }
    else
    {
        $params{'NUMPARTITIONS'} = 2;
    }
    $params{'PARTITION1'} = 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:file:/tmp/domains/foo.my.flat/disk.img'
        unless exists $params{'PARTITION1'};
    $params{'PARTITION2'} = 'swap:128Mb:swap:::file:/tmp/domains/foo.my.flat/swap.img'
        unless exists $params{'PARTITION2'};

    #
    #  Create a temporary directory, and make sure it is present.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );
    ok ( -d $dir, "The temporary directory was created: $dir" );

    #
    #  Save the environment.
    #
    my %SAVE_ENV = %ENV;

    #
    #  Update the environment with our parameters.
    #
    foreach my $p ( keys %params )
    {
        $ENV{$p} = $params{$p};
    }

    #
    #  Run the command
    #
    my $prefix = $ENV{AS_INSTALLED_TESTING} ? '/usr/' : 'perl ';
    system( "${prefix}bin/xt-create-xen-config --output=$dir --template=etc/xl.tmpl" );

    #
    #  Reset the environment
    #
    %ENV = %SAVE_ENV;



    #
    #  Read the Xen configuration file which the xt-creaat...
    # command wrote and return it to the caller.
    #
    open( OUTPUT, "<", $dir . "/foo.my.flat.cfg" );
    my @LINES = <OUTPUT>;
    close( OUTPUT );

    return( join( "\n", @LINES ), $dir );
}



=head2 testOutputContains

  Run the xt-create-xen-config and ensure that the output
 contains the text we're looking for.

=cut

sub testOutputContains
{
    my ( $text, %params ) = ( @_ );

    # Get the output of running the command.
    my ($output, $dir) = runCreateCommand( %params );

    #
    #  Look to see if we got the text.
    #
    my $found = 0;
    if ( $output =~ /\Q$text\E/ )
    {
        $found += 1;
    }

    ok( $found > 0, "We found the output we wanted: $text ($output)" );
}


=head2 noMentionOf

  Make sure that the creation of a given Xen configuration
 file contains no mention of the given string.

=cut

sub noMentionOf
{
    my ( $text, %params ) = ( @_ );

    # Get the output of running the command.
    my ($output, $dir) = runCreateCommand( %params );

    #
    #  Look to see if we got the text.
    #
    my $found = 0;
    if ( $output =~ /\Q$text\E/ )
    {
        $found += 1;
    }

    ok( $found == 0, "The output didn't contain the excluded text: $text ($output)" );

}
