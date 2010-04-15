#!/usr/bin/perl -w
#
#  Test that every shell script we have passes a syntax check.
#
# Steve
# --
#


use strict;
use File::Find;
use Test::More qw( no_plan );


#
#  Find all the files beneath the current directory,
# and call 'checkFile' with the name.
#
find( { wanted => \&checkFile, no_chdir => 1 }, '.' );



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

    # We don't care about directories
    return if ( ! -f $file );

    # Finally mercurial files are fine.
    return if ( $file =~ /\.(hg|git)\// );

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
    #  Now run 'sh -n $file' to see if we pass the syntax
    # check
    #
    my $retval = system( "sh -n $file 2>/dev/null >/dev/null" );

    is( $retval, 0, "Shell script passes our syntax check: $file" );
}
