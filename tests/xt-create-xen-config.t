#!/usr/bin/perl -w
#
#  Test that calling xt-create-xen-config with the appropriate parameters
# results in output we expect.
#
# Steve
# --
# $Id: xt-create-xen-config.t,v 1.1 2006-06-19 14:03:52 steve Exp $
#


use strict;
use Test::More qw( no_plan );
use File::Temp;


#
#  Look for mention of DHCP when setting up DHCP.
#
runCommand( "dhcp",  memory => 128, dhcp => 1, dir => '/tmp' );


#
#  Look for an IP address when specifying one.
#
runCommand( "ip=192.168.1.1",  memory => 128, ip1 => '192.168.1.1', dir => '/tmp' );

#
#  Look for SDA + HDA
#
runCommand( "sda1",   memory => 128, ip1 => '192.168.1.1', dir => '/tmp' );
runCommand( "sda2",   memory => 128, ip1 => '192.168.1.1', dir => '/tmp' );
runCommand( "hda1",   memory => 128, ip1 => '192.168.1.1', dir => '/tmp', ide => 1 );
runCommand( "hda2",   memory => 128, ip1 => '192.168.1.1', dir => '/tmp', ide => 1 );


sub runCommand
{
    my ($text, %params ) = ( @_ );

    #
    #  Force a hostname
    #
    $params{'hostname'} = 'foo.my.flat';

    #
    #  Create a temporary directory, and make sure it is present.
    #
    my $dir            = File::Temp::tempdir( CLEANUP => 1 );
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
    system( "./bin/xt-create-xen-config --output=$dir --template=./etc/xm.tmpl" );

    #
    #  Reset the environment
    #
    %ENV = %SAFE_ENV;



    #
    #  See if we found the output we wanted.
    #
    my $found = 0;
    my $match = '';

    open( OUTPUT, "<", $dir . "/foo.my.flat.cfg" );
    foreach my $line ( <OUTPUT> )
    {
        if ( $line =~ /\Q$text\E/ )
        {
            $found += 1;
            $match = $line;
        }
    }

    ok( $found > 0, "We found the output we wanted" );

}
exit;

#
#  Create a temporary directory, and make sure it is present.
#
my $dir            = File::Temp::tempdir( CLEANUP => 1 );
ok ( -d $dir, "The temporary directory was created: $dir" );


