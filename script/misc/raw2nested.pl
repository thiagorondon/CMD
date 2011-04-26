#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use FindBin qw($Bin);
use lib "../CMD/lib";
use CMD::Schema;

my $db     = '/home/thiago/cmd/CMD/cmd-novo-2009.db';
my $schema = CMD::Schema->connect("dbi:SQLite:dbname=$db");
my $rs     = $schema->resultset('Recurso');
&main;

sub check_file {
    my $filename = shift;
    open my $fh, '<', $filename or die "error: $@ \n";
    return $fh;
}

sub main {

    my $fh   = &check_file( $ARGV[0] );
    my %tree = &process_data($fh);

    $fh   = &check_file( $ARGV[1] );
    %tree = &process_data_transferencia( $fh, %tree );
    %tree = &proccess_values(%tree);

    #print Dumper( \%tree );
    my $root = $rs->create( { content => '2009', valor => 0 });
    &hash_to_db($root, %tree);
}

sub hash_to_db () {
    my $root = shift;
    my ( %tree ) = (@_);

    foreach my $item ( keys %tree ) {
        my $valor = $tree{$item};
        my $node;
        next if $item eq 'total';
        next if $item eq 'NomeFuncao'; # Hm ?
        if (ref($valor) eq 'HASH') {
            my $total = $tree{$item}{total} || 0;
            $node = $root->add_to_children( { content => $item, valor => $total } );
            &hash_to_db ($node, %{$valor});
        }
        else {
            $node =
                $root->add_to_children( { content => $item, valor => $valor } );
        }

    }

    #my $root = $tree->create({ id => 2, content => 'root', valor => 1 });
    #my $child = $root->add_to_children({ content => 'child', valor => 1 });
}

sub proccess_values {
    my (%tree) = (@_);
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
                                my $inv_mun = $tree{$i}{$j}{$k}{$l}{$m}{$n};
                                $total_repasse_municipio += $inv_mun
                                  if looks_like_number($inv_mun);
                            }
                            $total_repasse_estado += $total_repasse_municipio;
                            $tree{$i}{$j}{$k}{$l}{$m}{total} =
                              $total_repasse_municipio;
                        }
                        $tree{$i}{$j}{$k}{$l}{total} = $total_repasse_estado;
                        $total_repasse += $total_repasse_estado;
                    }

                    $tree{$i}{$j}{$k}{total} = $total_repasse;
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

sub fix_valor {
    my $v = shift;
    $v =~ s/\,/\./;
    $v =~ s/\'//g;
    $v =~ s/\n//;
    $v =~ s/\r//;
    return $v;
}

sub process_data_transferencia {
    my ( $fh, %tree ) = @_;
    my $header = 0;
    while ( my $row = <$fh> ) {
        $header++ and next unless $header;
        my @cols = split( /\;/, $row );
        map { $_ =~ s/\"//g; } @cols;
        my $valor = $cols[12];
        next unless $valor;
        my $estado    = $cols[0];
        my $municipio = $cols[2];
        my $funcao    = $cols[4];
        my $subfuncao = $cols[6];
        my $programa  = $cols[8];
        $valor = &fix_valor($valor);
        $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa} =
          $valor;
    }
    return %tree;
}

sub process_data {
    my $fh = shift;
    my %tree;
    my $header = 0;
    while ( my $row = <$fh> ) {
        $header++ and next unless $header;
        my @cols      = split( /\;/, $row );
        my $valor     = $cols[17];
        my $funcao    = $cols[9];
        my $subfuncao = $cols[11];
        my $programa  = $cols[13];
        $valor = &fix_valor($valor);
        $tree{$funcao}{$subfuncao}{$programa} = $valor;

    }
    return %tree;
}

