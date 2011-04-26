
use CMD::Schema;
my $db = '/home/thiago/cmd/CMD/cmd.db';
exit unless -r $db;

my $schema = CMD::Schema->connect("dbi:SQLite:dbname=$db");

my $tree = $schema->resultset('Recurso');

my $root = $tree->create({ id => 1, content => 'root', valor => 1.1 });
my $root2 = $tree->create({ id => 2, content => 'root2', valor => 1.2 });


my $child = $root->add_to_children({ content => 'child-root', valor => 1 });
$root->add_to_children({ content => 'child-root-2', valor => 3 });
my $ch_child = $child->add_to_children({ content => 'child-child-root', valor => 2 });

