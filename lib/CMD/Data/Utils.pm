
package CMD::Data::Utils;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT_FAIL);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(get_root_by_nodeid);

$VERSION = '0.01';
$VERSION = eval $VERSION;

sub get_root_by_nodeid {
    my $node = shift;
    my $root = $node;
    my $point = $node;
    while ($point) {
        my @parent;
        eval { @parent = $point->parents() };
        $root = $parent[0] if scalar @parent;
        $point = $point->parent;
    }
    return $root;
}

1;

