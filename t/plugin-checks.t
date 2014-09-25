#!perl -w
#
#  Test that the plugins each refer to environmental variables,
# not the perl config hash.
#
# Steve
# --
#


use strict;
use Test::More;


#
#  Rather than having a hardwired list of distributions to test
# against we look for subdirectories beneath hooks/ and test each
# one.
#
foreach my $dir ( glob( "hooks/*" ) )
{
    next if ( $dir =~ /CVS/i );
    next if ( $dir =~ /common/i );
    next if ( ! -d $dir );

    if ( $dir =~ /hooks\/(.*)/ )
    {
        my $dist = $1;
        testPlugins( $dist );
    }
}

done_testing();

=head2 testPlugins

  Test each plugin associated with the given directory.

=cut

sub testPlugins
{
    my ( $dist ) = ( @_ );

    #
    # Make sure there is a hook directory for the named distro
    #
    ok( -d "hooks/$dist/", "There is a hook directory for the distro $dist" );

    #
    # Make sure the plugins are OK.
    #
    foreach my $file ( glob( "hooks/$dist/*" ) )
    {
        ok( -e $file, "$file" );

        if ( -f $file )
        {
            ok( -x $file, "File is executable" );

            #
            #  Make sure the file is OK
            #
            my $result = testFile( $file );
            is( $result, 0, " File contains no mention of the config hash" );

        }
    }

}



#
#  Test that the named file contains no mention of '$CONFIG{'xx'};'
#
sub testFile
{
    my ( $file ) = ( @_ );

    open( FILY, "<", $file ) or die "Failed to open $file - $!";

    foreach my $line ( <FILY> )
    {
        if ( $line =~ /\$CONFIG{[ \t'"]+(.*)[ \t'"]+}/ )
        {
            close( FILY );
            return $line;
        }
    }
    close( FILY );

    #
    # Success
    #
    return 0;
}

