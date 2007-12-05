#!/usr/bin/perl -w
#
#  Test that every perl + shell script we have contains no tabs.
#
# Steve
# --
# $Id: no-tabs.t,v 1.1 2007-09-01 19:23:10 steve Exp $


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
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    # We don't care about directories
    return if ( ! -f $file );

    # Nor about backup files.
    return if ( $file =~ /~$/ );

    # Nor about files which start with ./debian/
    return if ( $file =~ /^\.\/debian\// );

    # Finally mercurial files are fine.
    return if ( $file =~ /\.hg\// );
    # See if it is a shell/perl file.
    my $isShell        = 0;
    my $isPerl        = 0;

    # Read the file.
    open( INPUT, "<", $file );
    foreach my $line ( <INPUT> )
    {
        if ( ( $line =~ /\/bin\/sh/ ) ||
             ( $line =~ /\/bin\/bash/ ) )
        {
            $isShell = 1;
        }
        if ( $line =~ /\/usr\/bin\/perl/ )
        {
            $isPerl = 1;
        }
    }
    close( INPUT );

    #
    #  Return if it wasn't a perl file.
    #
    if ( $isShell || $isPerl )
    {
        #
        #  Count TAB characters
        #
        my $count = countTabCharacters( $file );

        is( $count, 0, "Script has no tab characters: $file" );
    }
}


=head2 countTabCharacters

=cut

sub countTabCharacters
{
    my ( $file ) = (@_);

    my $count = 0;

    open( FILE, "<", $file )
      or die "Cannot open $file - $!";
    foreach my $line ( <FILE> )
    {
        while( $line =~ /(.*)\t(.*)/ )
        {
            $count += 1;
            $line = $1 . $2;
        }
    }
    close( FILE );

    return( $count );
}
