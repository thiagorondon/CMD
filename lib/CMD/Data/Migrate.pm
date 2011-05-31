
package CMD::Data::Migrate;

use utf8;
use Moose;
use Scalar::Util qw(looks_like_number);

has rs => (
    is        => 'rw',
    isa       => 'Object',
    predicate => 'has_rs'
);

has rs_cidade => (
    is  => 'rw',
    isa => 'Object',
    predicate => 'has_rs_cidade'
);

has year => (
    is  => 'rw',
    isa => 'Int'
);

sub hash_to_db () {
    my ( $self, $root, $treeref ) = @_;
    my %tree = %$treeref;

    die 'need to set rs' unless $self->has_rs;

    foreach my $item ( keys %tree ) {
        my $valor = $tree{$item};
        next if $item eq 'total';
        next if $item eq 'NomeFuncao';    # Hm ?
        if ( ref($valor) eq 'HASH' ) {
            my $total = $tree{$item}{total} || 0;
            my $node = $self->rs->create(
                { content => $item, valor => $total, parent_id => $root->id },
                ano => $self->year, cidade_codigo => 0 );
            $self->hash_to_db( $node, $valor );
        }
        else {
            my ( $valor_parcial, $codigo, $subfuncao, $funcao, $estado,
                $codmunicipio, $municipio )
              = split( '-', $valor );
    
            warn $valor_parcial if $valor_parcial;

            $self->rs_cidade->update_or_create({
                codigo => $codmunicipio,
                nome => $municipio,
                estado => $estado
            }) if $codmunicipio;

            #my $node = 
            $self->rs->create(
                {
                    content       => $item,
                    valor         => $valor,
                    codigo        => $codigo,
                    subfuncao     => $subfuncao,
                    funcao        => $funcao,
                    cidade_codigo => $codmunicipio || 0,
                    estado       => $estado,
                    parent_id     => $root->id,
                    ano           => $self->year
                }
            );
        }

    }
}

sub proccess_values {
    my ( $self, %tree ) = (@_);
    my $total = 0;

    # Funções
    foreach my $i ( keys %tree ) {
        my $funcao       = $tree{$i};
        my $total_funcao = 0;

        # Sub-funções
        foreach my $j ( keys %{$funcao} ) {
            my $subfuncao       = $tree{$i}{$j};
            my $total_subfuncao = 0;

            # Programas
            foreach my $k ( keys %{$subfuncao} ) {
                my $investimento = $tree{$i}{$j}{$k};

                ($investimento) = split( '-', $tree{$i}{$j}{$k} )
                  unless ref($investimento) eq 'HASH';

                # Repasse
                if ( ref($investimento) eq 'HASH' ) {
                    my $total_repasse = 0;

                    # Estados
                    foreach my $l ( keys %{$investimento} ) {
                        my $total_repasse_estado = 0;

                        # Municipio
                        my $estado = $tree{$i}{$j}{$k}{$l};
                        foreach my $m ( keys %{$estado} ) {
                            my $total_repasse_municipio = 0;

                            # Programa
                            my $municipio = $tree{$i}{$j}{$k}{$l}{$m};
                            foreach my $n ( keys %{$municipio} ) {
                                my ($inv_mun) =
                                  split( '-', $tree{$i}{$j}{$k}{$l}{$m}{$n} );
                                $total_repasse_municipio += $inv_mun
                                  if looks_like_number($inv_mun);
                                print "$inv_mun\n"
                                  unless looks_like_number($inv_mun);
                            }
                            $total_repasse_estado += $total_repasse_municipio;
                            $tree{$i}{$j}{$k}{$l}{$m}{total} =
                              $total_repasse_municipio;
                        }

                        $tree{$i}{$j}{$k}{$l}{total} = $total_repasse_estado;
                        $total_repasse += $total_repasse_estado;
                    }

                    $tree{$i}{$j}{$k}{total} = $total_repasse;
                    $total_subfuncao += $total_repasse;
                }

                $total_subfuncao += $investimento
                  if looks_like_number($investimento);

            }

            $tree{$i}{$j}{total} = $total_subfuncao;
            $total_funcao += $total_subfuncao;
        }
        $tree{$i}{total} = $total_funcao;
        $total += $total_funcao;
    }
    return %tree;
}

1;

