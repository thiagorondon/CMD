
use CMD::Schema;
my $db = '/home/thiago/cmd/CMD/cmd-novo-2009.db';
exit unless -r $db;

my $schema = CMD::Schema->connect("dbi:SQLite:dbname=$db");

my $sc = $schema->resultset('Recurso')->find({ content => '2009' });
#my $sc = $schema->resultset('Recurso')->find( { id => 89384 } );


foreach my $item ($sc->children) {
#    next if $item->id != 89384;
    &fix_total($item);
}

sub fix_total () {
    my $tree = shift;

    my $total = 0;
    foreach my $item ( $tree->children ) {
        print $item->id . " = " . $item->content . " => " . $item->valor . "\n";
        $total += $item->valor;

        my $subtotal = 0;

        foreach my $item2 ( $item->children ) {
            print "1\n" and next if $item2->content eq 'total';
            $subtotal += $item2->valor;

           #    my $subsubtotal = 0;
           #    if ($item2->children) {
           #        foreach my $item3 ($item2->children) {
           #            $subsubtotal += $item3->valor;
           #        }
           #        print "subsubtotal: $subsubtotal (" . $item2->valor . ")\n";
           #    }

        }
        print "subtotal: $subtotal\n";
        $item->update({ valor => $subtotal });
        $total += $subtotal;
    }
    print "total: $total\n";
    $tree->update({ valor => $total });
}

