#!perl -w
#
#  Test that every perl + shell script we have contains no tabs.
#
# Steve
# --
#


use strict;
use File::Find;
use Test::More;
use Test::NoTabs;

#
#  Find all the files beneath the current directory,
# and call 'checkFile' with the name.
#
find( { wanted => \&checkFile, no_chdir => 1 }, '.' );

#
#  Check a file.
#
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    # We don't care about directories or symbolic links
    return if ( ! -f $file );
    return if (   -l $file );

    # Nor about backup files.
    return if ( $file =~ /~$/ );

    # Nor about Makefiles
    return if ( $file =~ /\/Makefile$/ );

    # Nor about dot files
    return if ( $file =~ m{/\.[^/]+$} );

    # Nor about files which start with ./debian/
    return if ( $file =~ /^\.\/debian\// );

    # Nor about Changlog
    return if ( $file =~ /^\.\/ChangeLog$/ );

    # Finally mercurial and git files are fine.
    return if ( $file =~ /\.(hg|git)\// );
    # See if it is a shell/perl file.
    my $isShell        = 0;
    my $isPerl        = 0;


    if ( $file =~ /\.sh$/ ) {
        $isShell = 1;
    } elsif ( $file =~ /\.(pl|pm|t)$/ ) {
        $isPerl = 1;
    } else {

        # Read the file.
        open( INPUT, "<", $file );
        foreach my $line ( <INPUT> )
        {
            if ( ( $line =~ /^#! *\/bin\/sh/ ) ||
                 ( $line =~ /^#! *\/bin\/bash/ ) )
            {
                $isShell = 1;
                last;
            }
            if ( $line =~ /^#!.*\bperl\b/ )
            {
                $isPerl = 1;
                last;
            }
        }
        close( INPUT );
    }

    #
    #  Run check if it is a shell file.
    #
    notabs_ok( $file ) if $isShell or $isPerl;
}

done_testing();
