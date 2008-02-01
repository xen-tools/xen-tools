#!/usr/bin/perl -w
#
#  Test that we don't use non-portable shell syntax in our hooks.
#
#  Specifically we test for:
#
# 1.  "[[" & "]]" around tests.
#
# 2.  The "function" keyword
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

    # We're only testing things beneath hooks
    return if ( $file !~ /hooks/ );

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
    #  Return if it wasn't a shell script.
    #
    return if ( ! $isShell );


    # The result
    my $result = 0;

    #
    #  Open the file and read it.
    #
    open( INPUT, "<", $file )
      or die "Failed to open '$file' - $!";

    while( my $line = <INPUT> )
    {
        # [[ or ]]
        $result += 1 if ( $line =~ /\[\[/ );
        $result += 1 if ( $line =~ /\]\]/ );

        # function
        $result += 1 if ( $line =~ /^[ \t]*function/ );
    }
    close( INPUT );

    is( $result, 0, "Shell script passes our portability check: $file" );
}
