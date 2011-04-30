use strict;
use warnings;
use Test::More;
use Catalyst::Test 'CMD';
use HTTP::Request::Common;

ok( my $controller = CMD->controller('Root') );

done_testing();

