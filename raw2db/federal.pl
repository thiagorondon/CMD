#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use FindBin qw($Bin);
use lib "../lib";
use CMD::Schema;
use Data::Dumper;

my $total_test = 0;
my $schema = CMD::Schema->connect( "dbi:mysql:db=cmd", "cmd", "aviao" );
my $rs = $schema->resultset('Node');
my $year;

&main;

sub check_file {
    my $filename = shift;
    open my $fh, '<', $filename or die "error: $@ \n";
    return $fh;
}

sub main {

    if (!$ARGV[2]) {
        print "Use: ./script.pl ano diretas.csv transferencia.csv\n";
        exit 0;
    }

    $year = $ARGV[0];
    my $fh   = &check_file( $ARGV[1] );
    my %tree = &process_data($fh);

    $fh   = &check_file( $ARGV[2] );
    %tree = &process_data_transferencia( $fh, \%tree );
    %tree = &proccess_values(%tree);

    #print "re: $total_test\n";
    #return;
    my $root = $rs->create( { content => $year, valor => 0 } );
    &hash_to_db( $root, \%tree );
}

sub hash_to_db () {
    my ($root, $treeref) = @_;
    my %tree = %$treeref;

    foreach my $item ( keys %tree ) {
        my $valor = $tree{$item};
        next if $item eq 'total';
        next if $item eq 'NomeFuncao';    # Hm ?
        if ( ref($valor) eq 'HASH' ) {
            my $total = $tree{$item}{total} || 0;
            my $node = $rs->create( { content => $item, valor => $total, parent_id => $root->id }, year => $year );
            &hash_to_db( $node, $valor );
        }
        else {
            my ( $valor_parcial, $codigo, $subfuncao, $funcao, $estado,
                $codmunicipio, $municipio )
              = split( '-', $valor );
            my $node = $rs->create(
                {
                    content      => $item,
                    valor        => $valor,
                    codigo       => $codigo,
                    subfuncao    => $subfuncao,
                    funcao       => $funcao,
                    estado       => $estado,
                    codmunicipio => $codmunicipio,
                    municipio    => $municipio,
                    parent_id   => $root->id,
                    year => $year
                }
            );
        }

    }
}

sub proccess_values {
    my (%tree) = (@_);
    my $total = 0;

    # Funções
    foreach my $i ( keys %tree ) {
        my $funcao       = $tree{$i};
        my $total_funcao = 0;
        #print "$i\n";
        #next unless $i eq 'Educação';


        # Sub-funções
        foreach my $j ( keys %{$funcao} ) {
            my $subfuncao       = $tree{$i}{$j};
            my $total_subfuncao = 0;

            # Programas
            foreach my $k ( keys %{$subfuncao} ) {
                my $investimento = $tree{$i}{$j}{$k};
                
                ($investimento) = split( '-', $tree{$i}{$j}{$k} ) unless ref($investimento) eq 'HASH';
                
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
                                print "$inv_mun\n" unless looks_like_number($inv_mun);
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

                if ($k eq 'Brasil Escolarizado') {
                    $total_test += $investimento;
                }

                $total_subfuncao += $investimento
                  if looks_like_number($investimento);
                #print "i:$investimento\n" unless looks_like_number($investimento);
 
            
            }

            $tree{$i}{$j}{total} = $total_subfuncao;
            $total_funcao += $total_subfuncao;
        }
        $tree{$i}{total} = $total_funcao;
        $total += $total_funcao;
    }
    return %tree;
}

sub fix_valor {
    my $v = shift;
    $v =~ s/\,/\./;
    $v =~ s/\'//g;
    $v =~ s/\n//;
    $v =~ s/\r//;
    return $v;
}

sub process_data_transferencia {
    my ($fh, $treeref) = @_;
    my %tree = %$treeref;
    my $header = 0;
    while ( my $row = <$fh> ) {
        $header++ and next unless $header;
        my @cols = split( /\;/, $row );
        map { $_ =~ s/\"//g; } @cols;
        my $valor = $cols[12];
        next unless $valor;
        my ($estado, $codmunicipio, $municipio, $codfuncao, $funcao, $codsubfuncao, $subfuncao, $codprograma, $programa) = @cols;

        #my $estado       = $cols[0];
        #my $codmunicipio = $cols[1];
        #my $municipio    = $cols[2];
        #my $codfuncao    = $cols[3];
        #my $funcao       = $cols[4];
        #my $codsubfuncao = $cols[5];
        #my $subfuncao    = $cols[6];
        #my $codprograma  = $cols[7];
        #my $programa     = $cols[8];
        $valor = &fix_valor($valor);

        if (!defined($tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa})) {
            $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa} = "0-";
        }

        my ($last_valor) = split('-', $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa});

        $last_valor += $valor;

        $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa} =
"$last_valor-$codprograma-$codsubfuncao-$codfuncao-$estado-$codmunicipio-$municipio";
    }
    return %tree;
}

sub process_data {
    my $fh = shift;
    my %tree;
    my $header = 0;
    while ( my $row = <$fh> ) {
        $header++ and next unless $header;
        my @cols         = split( /\;/, $row );
        my $valor        = $cols[17];
        my $codfuncao    = $cols[8];
        my $funcao       = $cols[9];
        my $codsubfuncao = $cols[10];
        my $subfuncao    = $cols[11];
        my $codprograma  = $cols[12];
        my $programa     = $cols[13];
        $valor = &fix_valor($valor);


        if (!defined($tree{$funcao}{$subfuncao}{$programa})) {
            $tree{$funcao}{$subfuncao}{$programa} = "0-";
        }

        my ($last_valor) = split('-', $tree{$funcao}{$subfuncao}{$programa} );
        $last_valor += $valor;

        $tree{$funcao}{$subfuncao}{$programa} =
          "$last_valor-$codprograma-$codsubfuncao-$codfuncao";

    }
    return %tree;
}

