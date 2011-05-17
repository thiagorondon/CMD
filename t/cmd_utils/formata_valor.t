use strict;
use warnings;
use Test::More;
use Test::More;

use CMD::Utils qw(formata_valor);

is(formata_valor('112'), 'R$ 112,00');
is(formata_valor('112444'), 'R$ 112.444,00');
is(formata_valor('112444555'), 'R$ 112 Mi');
is(formata_valor('112444555666'), 'R$ 112 Bi');
is(formata_valor('1124445556667'), 'R$ 1 Tri');

done_testing();

