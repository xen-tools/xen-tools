#!/usr/bin/perl -w
#
#  Test that the xen-list-images script can process two "fake"
# installations which we construct manually.
#
#
# Steve
# --
#


use strict;
use Test::More qw( no_plan );
use File::Temp;


#
#  Test some random instances.
#
testRandomInstance( "foo.my.flat", 0 );
testRandomInstance( "foo.my.flat", 1 );

testRandomInstance( "bar.my.flat", 0 );
testRandomInstance( "bar.my.flat", 1 );

testRandomInstance( "baz.my.flat", 0 );
testRandomInstance( "baz.my.flat", 1 );



=head2 testRandomInstance

  Create a fake Xen configuration file and test that the xen-list-images
 script can work with it.

=cut

sub testRandomInstance
{
    my ( $name, $dhcp ) = ( @_ );

    # Create a temporary directory.
    my $dir = File::Temp::tempdir( CLEANUP => 1 );
    ok ( -d $dir, "The temporary directory was created for test: $name" );


    #
    #  Generate a random amount of memory
    #
    my $memory = int( rand( 4096 ) );

    #
    #  Generate a random IP address.
    #
    my $ip    = '';
    my $count = 0;
    while( $count < 4 )
    {
        $ip .= int( rand( 256 ) ) . ".";

        $count += 1;
    }


    #
    #  Write a xen configuration file to the temporary directory.
    #
    open( TMP, ">", $dir . "/foo.cfg" );

    if ( $dhcp )
    {
        print TMP <<EOD;
kernel  = '/boot/vmlinuz-2.6.16-2-xen-686'
ramdisk = '/boot/initrd.img-2.6.16-2-xen-686'
memory  =  $memory
name    = '$name'
root    = '/dev/sda1 ro'
disk    = [ 'phy:skx-vg/foo.my.flat-disk,sda1,w', 'phy:skx-vg/foo.my.flat-swap,sda2,w' ]
dhcp  = "dhcp"
EOD
    }
    else
    {
        print TMP <<EOS;
kernel  = '/boot/vmlinuz-2.6.16-2-xen-686'
ramdisk = '/boot/initrd.img-2.6.16-2-xen-686'
memory  =  $memory
name    = '$name'
root    = '/dev/sda1 ro'
disk    = [ 'phy:skx-vg/foo.my.flat-disk,sda1,w', 'phy:skx-vg/foo.my.flat-swap,sda2,w' ]
vif  = [ 'ip=$ip' ]
EOS
    }
    close( TMP );


    #
    #  Now run the xen-list-images script to make sure we can read
    # the relevant details back from it.
    #
    my $cmd = "./bin/xen-list-images --test=$dir";
    my $output = `$cmd`;

    ok( defined( $output ) && length( $output ), "Runing the list command produced some output" );

    #
    #  Process the output of the command, and make sure it was correct.
    #
    my $success = 0;
    foreach my $line ( split( /\n/, $output ) )
    {
        if  ( $line =~ /Memory: ([0-9]+)/i )
        {
            is( $1, $memory, "We found the right amount of memory: $memory" );
            $success += 1;
        }
        if  ( $line =~ /Name: (.*)/i )
        {
            is( $1, $name, "We found the correct hostname: $name" );
            $success += 1;
        }
        if  ( $line =~ /DHCP/i )
        {
            is( $dhcp, 1, "Found the right DHCP details" );
            $success += 1;
        }
        if  ( $line =~ /IP: ([0-9.]+)/i )
        {
            is( $1, $ip, "We found the IP address: $ip" );
            is( $dhcp, 0, "And DHCP is disabled" );
            $success += 1;
        }
    }

    is( $success, 3, "All output accounted for!" );
}
