#!perl -w
#
#  Test that every perl script accepts and processes each of the options
# documented in its POD.
#
#  Cute test :)
#
# Steve
# --
#


use strict;
use File::Find;
use Test::More;


#
#  Test each file
#
foreach my $file ( sort( glob "./bin/*-*" ) )
{
    # Skip emacs and CVS backups
    next if $file =~ /~$/;

    testFile( $file );
}

done_testing();

#
#  Check that the given file implements all the option processing it
# is supposed to.
#
#
sub testFile
{
    my ($file ) = (@_);
    is( -e $file, 1, "File exists: $file" );
    is( -x $file, 1, "File is executable" );

    #
    #  Run the file with "--help" and capture the output.
    #
    my $output = `perl -Ilib $file --help`;

    #
    #  Parse out the options we accept
    #
    my @documented = ();

    foreach my $line ( split( /\n/, $output ) )
    {
        if ( $line =~ /[ \t]*--(?:\(no\))?([a-z0-9-_]+)/ )
        {
            push @documented, $1 unless( $line =~ /NOP/i );
        }
    }

    #
    #  Test we discovered some documented options.
    #
    ok( $#documented > 1, "We found some options documented in $file." );



    #
    #  Now read the input file so that we can see if these advertised
    # options are actually used.
    #
    open( IN, "<", $file ) or die "Failed to open file for reading $file - $!";
    my @LINES = <IN>;
    close( IN );

    #
    #  Options accepted
    #
    my %accepted;

    #
    #  Do minimal parsing to find the options we process with
    # Getopt::Long;
    #
    my $complete = join( "\n", @LINES );
    if ( $complete =~ /GetOptions\(([^\)]+)\)/mi )
    {
        #
        #  Multi-line text which should have all the options we've
        # invoked GetOptions with.
        #
        my $opt = $1;

        #
        #  Process each one.
        #
        foreach my $o ( split( /\n/, $opt ) )
        {
#print "O: $o ";
            #
            #  Strip trailing comments.
            #
            if ( $o =~ /([^#]+)#/ )
            {
                $o = $1;
            }
#print " - strip comments : $o ";

            #
            #  Remove "" or '' around it.
            #
            if ( $o =~ /(["'])([^"']+)\1/ )
            {
                $o = $2;
            }
#print " - remove quotes : $o ";
            #
            #  Discard anything after "=", ":", or " "
            #
            if ( $o =~ /(.*)[ \t=:]+(.*)/ )
            {
                $o = $1;
            }
#print " - remove negation : $o ";
            #
            #  Discard any "!" at the end
            #
            $o =~ s/!//;
#print " - remove = : $o ";
            #
            #  Now avoid blank lines.
            #
            next if ( $o =~ /^[ \t]*$/ );

            #
            #  Now split at pipe
            #
            foreach my $osplit (split(/\|/, $o)) {

                #
                #  Phew.  Now we're done.
                #
                #  This option '$osplit' is something we call GetOptions with.
                #
                $accepted{$osplit} = 1;
            }
        }
    }

    #
    #  Now we want to make sure that each documented option is
    # present in the list of options we pass to getopt.
    #
    foreach my $argument ( @documented )
    {
        is( $accepted{$argument}, 1, "Option '--$argument' accepted: $file" );
    }
}
