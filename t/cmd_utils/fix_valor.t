use strict;
use warnings;
use Test::More;
use Test::More;

use CMD::Utils qw(fix_valor);

my $valor = '1,23';
is(fix_valor($valor), 1.23);

# NEED TO FIX
#$valor = '1.232,23';
#is(fix_valor($valor), 1232.23);

$valor = '12323,23';
is(fix_valor($valor), 12323.23);

$valor = "'12,23'";
is(fix_valor($valor), 12.23);

$valor = '34.45';
is(fix_valor($valor), 34.45);

$valor = '2832.1';
is(fix_valor($valor), 2832.1);

$valor = '231';
is(fix_valor($valor), 231);

done_testing();

