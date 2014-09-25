#!perl -w -I..
#
#  Test that we have several required programs present.
#
# Steve
# --
#

use Test::More;


#
#  Files that we want to use.
#
my @required = qw( /bin/ls /bin/dd /bin/mount /bin/cp /bin/tar );

#
#  Files that we might wish to use.
#
my @optional = qw( /usr/sbin/debootstrap /usr/bin/rpmstrap /usr/sbin/xm
                   /sbin/mkfs.ext3 /sbin/mkfs.xfs /sbin/mkfs.reiserfs
                   /sbin/mkfs.btrfs
               );



#
#  Test required programs
#
foreach my $file ( @required )
{
    ok( -x $file , "Required binary installed: $file" );
}

#
#  Test optional programs - if they exist then we ensure they are
# executable.  If they don't we'll not complain since they are optional.
#
foreach my $file ( @optional )
{
    if ( -e $file )
    {
        ok( -x $file , "Optional binary installed: $file" );
    }
}

done_testing();
