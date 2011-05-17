
use Test::More;
use DBICx::TestDatabase;
use CMD::Data::Utils qw(get_root_by_nodeid);

my $schema = DBICx::TestDatabase->new('CMD::Schema');
my $rs_node = $schema->resultset('Node');

my $root = $rs_node->create({
node_id => 1, parent_id => 0, position => 1, lft => 0, rgt => 0,
content => '2010', valor => '123', codigo => '1', funcao => 0,
subfuncao => 0, cidade_codigo => 0, ano => 2010
});

my $obj = get_root_by_nodeid($root);
is($obj->content, '2010');

my $parent = $rs_node->create({
node_id => 2, parent_id => $root->id, position => 1, lft => 0, rgt => 0,
content => '2010', valor => '123', codigo => '1', funcao => 0,
subfuncao => 0, cidade_codigo => 0, ano => 2010
});

$obj = get_root_by_nodeid($parent);
is($obj->content, '2010');


done_testing();

