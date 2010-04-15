#!/usr/bin/perl -w
#
#  Test that every perl file we have passes the syntax check.
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
#  If this is a perl file then call "perl -c $name", otherwise
# return
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    # We don't care about directories
    return if ( ! -f $file );

    # Nor about Makefiles
    return if ( $file =~ /\/Makefile$/ );

    # `modules.sh` is a false positive.
    return if ( $file =~ /modules.sh$/ );

    # `tests/hook-tls.t` is too.
    return if ( $file =~ /hook-tls.t$/ );

    # See if it is a perl file.
    my $isPerl = 0;

    # Read the file.
    open( INPUT, "<", $file );
    foreach my $line ( <INPUT> )
    {
        if ( $line =~ /\/usr\/bin\/perl/ )
        {
            $isPerl = 1;
        }
    }
    close( INPUT );

    #
    #  Return if it wasn't a perl file.
    #
    return if ( ! $isPerl );

    #
    #  Now run 'perl -c $file' to see if we pass the syntax
    # check.  We add a couple of parameters to make sure we're
    # really OK.
    #
    #        use strict "vars";
    #        use strict "subs";
    #
    my $retval = system( "perl -Mstrict=subs -Mstrict=vars -c $file 2>/dev/null >/dev/null" );

    is( $retval, 0, "Perl file passes our syntax check: $file" );
}
