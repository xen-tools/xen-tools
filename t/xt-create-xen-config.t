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
testOutputContains( "/dev/xvda1 ro",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp' );
noMentionOf( "hda1",
             memory => 128, ips => '192.168.1.1', dir => '/tmp' );


#
#  IDE based systems
#
testOutputContains( "hda1",
                    memory => 128, ips => '192.168.1.1', dir => '/tmp', ide => 1 );
testOutputContains( "/dev/hda1 ro",
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
testOutputContains( "phy:",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy::/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy::/dev/skx-vg0/swap' );
testOutputContains( "skx-vg0",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy::/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy::/dev/skx-vg0/swap' );
noMentionOf( "/tmp",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy::/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy::/dev/skx-vg0/swap' );
noMentionOf( "domains",
                    memory => 128, dhcp => 1, lvm => 'skx-vg0',
                    PARTITION1 => 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:phy::/dev/skx-vg0/disk',
                    PARTITION2 => 'swap:128Mb:swap:::phy::/dev/skx-vg0/swap' );


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



done_testing();




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
    $params{'NUMPARTITIONS'} = 2;
    $params{'PARTITION1'} = 'disk:4Gb:ext3:/:noatime,nodiratime,errors=remount-ro:file::/tmp/domains/foo.my.flat/disk.img'
        unless exists $params{'PARTITION1'};
    $params{'PARTITION2'} = 'swap:128Mb:swap:::file::/tmp/domains/foo.my.flat/swap.img'
        unless exists $params{'PARTITION2'};

    #
    #  Create a temporary directory, and make sure it is present.
    #
    my $dir = File::Temp::tempdir( CLEANUP => 1 );
    ok ( -d $dir, "The temporary directory was created: $dir" );

    #
    #  Save the environment.
    #
    my %SAFE_ENV = %ENV;

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
    system( "perl bin/xt-create-xen-config --output=$dir --template=etc/xm.tmpl" );

    #
    #  Reset the environment
    #
    %ENV = %SAFE_ENV;



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

    ok( $found == 0, "The output didn't contain the excluded text: $text" );

}
