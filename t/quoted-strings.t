#!perl -w
#
#  Test that every bash script using variables uses " not ' around the
#  variable.
#
# Steve
# --
#


use strict;
use File::Find;
use Test::More;


#
#  Find all the files beneath the current directory,
# and call 'checkFile' with the name.
#
my $dir = undef;
$dir = "../hooks" if ( -d "../hooks" );
$dir = "./hooks"  if ( -d "./hooks" );
ok( defined( $dir ), "Found hook directory" );
find( { wanted => \&checkFile, no_chdir => 1 }, $dir );

done_testing();

#
#  Check a file; if it is a shell script.
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    # We don't care about directories or symbolic links
    return if ( ! -f $file );
    return if (   -l $file );

    # Finally mercurial files are fine.
    return if ( $file =~ /\.hg\// );

    # See if it is a shell script.
    my $isShell = 0;

    # Read the file.
    open( INPUT, "<", $file );
    foreach my $line ( <INPUT> )
    {
        if ( ( $line =~ /\/bin\/sh/ ) ||
             ( $line =~ /\/bin\/bash/ ) )
        {
            $isShell = 1;
        }
    }
    close( INPUT );

    #
    #  Return if it wasn't a perl file.
    #
    return if ( ! $isShell );

    #
    #  Now read the file.
    #
    open( FILE, "<", $file ) or die "Failed to open file: $file - $!";
    ok( *FILE, "Opened file: $file" );
    foreach my $line (<FILE> )
    {
        chomp( $line );

        next if (!length( $line ) );
        next if ( $line =~ /grep|sed|echo|awk|find|policy-rc.d|chroot|logMessage/ );
        if ( $line =~ /\$/ )
        {
            ok( $line !~ /\'.*\$\.*\'/, "Non-masked line '$line' in '$file'" );
        }
    }
    close( FILE );
}
