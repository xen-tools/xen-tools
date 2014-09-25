#!perl -w
#
#  Test that every shell script we have passes a syntax check.
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
find( { wanted => \&checkFile, no_chdir => 1 }, '.' );

done_testing();

#
#  Check a file.
#
#  If this is a shell script then call "sh -n $name", otherwise
# return
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    # We don't care about directories or symbolic links
    return if ( ! -f $file );
    return if (   -l $file );

    # We don't care about empty files
    return unless -s $file;

    # Finally mercurial/git files are fine.
    return if ( $file =~ /^\.\/\.(hg|git)\// );

    # See if it is a shell script.
    my $isShell = 0;

    # Read the shebang
    open( INPUT, "<", $file );
    my $line = <INPUT>;
    close( INPUT );

    # Check if it is really a shell file
    if ( $line =~ /^#! ?\/bin\/sh/ )
    {
        $isShell = 1;
    }

    #
    #  Return if it wasn't a shell file.
    #
    return if ( ! $isShell );

    #
    #  Now run 'sh -n $file' to see if we pass the syntax
    # check
    #
    my $retval = system( "sh -n $file 2>/dev/null >/dev/null" );

    is( $retval, 0, "Shell script passes our syntax check: $file" );
}
