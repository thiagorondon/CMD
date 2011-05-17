use strict;
use warnings;
use Test::More;
use Test::More;

use CMD::Utils qw(formata_real);

is(formata_real('112',2, 1), '112,00');
is(formata_real('2.112',2, 1), '2.112,00');
is(formata_real('3.112,12',2, 1), '3.112,12');
is(formata_real('3.112,13',1, 1), '3.112,10');

done_testing();

