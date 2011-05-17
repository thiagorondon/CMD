use strict;
use warnings;
use Test::More;
use Test::JSON;
use Catalyst::Test 'CMD';
use HTTP::Request::Common;

ok( my $controller = CMD->controller('Data') );

my ($res, $c) = ctx_request('/data/base2nodes/1');
is (ref($c->stash->{data}), 'ARRAY');
is_valid_json $res->content;

($res, $c) = ctx_request('/data/node2base/1');
is_valid_json $res->content;

($res, $c) = ctx_request('/data/node/1');
is_valid_json $res->content;

done_testing();

