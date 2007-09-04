#!/usr/bin/perl
#
#  Test that the POD we use in our modules is valid.
#

use strict;
use warnings;
use Test::More;

# Ensure a recent version of Test::Pod
my $min_tp = 1.08;
eval "use Test::Pod $min_tp";

plan skip_all => "Test::Pod $min_tp required for testing POD" if $@;

#
#  Run the test(s).
#
all_pod_files_ok();
