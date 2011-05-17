
use Test::More;
use DBICx::TestDatabase;

my $schema = DBICx::TestDatabase->new('CMD::Schema');
my $rs_base = $schema->resultset('Base');
my $rs_basenode = $schema->resultset('BaseNode');
my $rs_node = $schema->resultset('Node');

$rs_node->create({
	node_id => 1,
	parent_id => 0,
	position => 1,
	lft => 0,
	rgt => 0,
	content => '2010',
	valor => '123',
	codigo => '1',
	funcao => 0,
	subfuncao => 0,
	cidade_codigo => 0,
	ano => 2010
});

ok($rs_node->find(1));

$rs_base->create({ id => 1, nome => 'Foo' });

ok($rs_base->find(1));

$rs_basenode->create({ node_id => 1, base_id => 1 });

ok($rs_basenode->search({ node_id => 1, base_id => 1 }));

done_testing();

