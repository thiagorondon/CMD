use strict;
use warnings;
use Test::More;


use Catalyst::Test 'CMD';
use CMD::Controller::API;

ok( request('/api')->is_success, 'Request should succeed' );
done_testing();
