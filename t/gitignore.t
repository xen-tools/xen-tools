#!/usr/bin/perl -w
#
#  Test that .gitignore is coherent
#
# Stéphane (kwisatz) Jourdois
# --
#

use strict;
use Test::More tests => 3;

BEGIN { use_ok( 'Git' ); }


# First, check that no tracked files are ignored
my $cmd = Git::command_output_pipe('ls-files', '--ignored', '--exclude-standard');
my $output;
while (<$cmd>) { $output .= "--> $_" }
close $cmd;

ok(!defined $output, 'No tracked file is ignored')
    or diag(<<EOF

Check that the following tracked files _have_to_ be ignored, and then either :
    - 'git rm' them
    - modify .gitignore to not ignore them
EOF
    . $output . "\n");


# Now, check that no untracked files are present
$cmd = Git::command_output_pipe('ls-files', '--others', '--exclude-standard');
undef $output;
while (<$cmd>) { $output .= "--> $_" }
close $cmd;

ok(!defined $output, 'No untracked file is present')
    or diag(<<EOF

Check whether the following untracked files have to be ignored or
tracked, and either :
    - 'git add' them
    - modify .gitignore to ignore them
EOF
    . $output . "\n");
