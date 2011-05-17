use strict;
use warnings;
use Test::More;
use Test::More;

use CMD::Utils qw(formata_float );

is(formata_float('1.23',1), '1.2');
is(formata_float('1.23',2), '1.23');
is(formata_float('1.12',1, ','), '1,1');

done_testing();

