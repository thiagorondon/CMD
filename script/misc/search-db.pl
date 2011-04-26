
use CMD::Schema;
my $db = '/home/thiago/cmd/CMD/cmd-novo-2009.db';
exit unless -r $db;

my $schema = CMD::Schema->connect("dbi:SQLite:dbname=$db");


#my $sc = $schema->resultset('Recurso')->find({ content => '2009' });
my $sc = $schema->resultset('Recurso')->find( { id => 30976 } );

foreach my $item ($sc->children) {
    print $item->id . "\n";
    print $item->children . "\n";
}

