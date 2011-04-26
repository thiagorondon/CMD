
package CMD::Utils;

use strict;
use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT_FAIL);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(formata_valor formata_float formata_real bgcolor);

$VERSION = '0.01';
$VERSION = eval $VERSION;

# TODO: R$, here ?
sub formata_valor {
    my $valor = shift;
    my ( $real, $centavo ) = split( /\./, $valor );

    my $return_real = &formata_real($real);
    $return_real =~ s/\..*//;

    if ( length("$real") > 6 and length("$real") < 10 ) {
        return 'R$ ' . $return_real . " Mi";
    }

    if ( length("$real") > 9 and length("$real") < 13 ) {
        return 'R$ ' . $return_real . " Bi";
    }

    if ( length("$real") > 12 and length("$real") < 16 ) {
        return 'R$ ' . $return_real . " Tri";
    }

    return 'R$ ' . &formata_real( "$real,$centavo", 2, 1 );
}

sub formata_float {
    my ( $valor, $n, $sep ) = @_;
    $sep ||= '.';
    my ( $j, $i ) = split( /\./, $valor );
    return $j . $sep . substr( $i, 0, $n );
}

# this is not real.
sub formata_real {
    my ( $valor, $ndec, $virgula ) = @_;
    my ( $j, $i );
    if ($virgula) {
        ( $j, $i ) = split( /\,/, $valor );
    }
    else {
        ( $j, $i ) = split( /\./, $valor );
    }

    $i = substr( $i, 0, $ndec ) if $ndec;
    $j =~ s/(?<!\.\d)(?<=\d)(?=(?:\d\d\d)+\b)/\./g;
    $i ||= '00';
    $i .= '0' if length($i) == 1;
    return "$j,$i";
}

sub bgcolor {
    qw/
      #c51d18
      #002974
      #56a468
      #98da60
      #54a4a1
      #cb3072
      #4266ba
      #3b7d03
      #ed733c
      #ff6281
      #ffe94d
      #388885
      #36832f
      #4c1f7d
      #156327
      #92a112
      #e8c428
      #85d397
      #4478c3
      #5f6e00
      #59a9a6
      #eba12f
      #4e82cd
      #21716e
      #72c6ff
      #ae0601
      #97a617
      #380035
      #000037
      #2f2b87/;
}

1;

