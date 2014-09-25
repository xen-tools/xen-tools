package File::Which;

# Mockup package to _not_ find anything

use strict;
use warnings;

use Exporter;

use vars qw{@ISA @EXPORT @EXPORT_OK};
BEGIN {
    @ISA       = 'Exporter';
    @EXPORT    = 'which';
}

sub which {
    return;
}

'This is a fake!';
