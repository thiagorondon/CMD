#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use FindBin qw($Bin);
use lib "../lib";
use CMD::Schema;
use CMD::Utils qw(fix_valor);
use CMD::Data::Migrate;
use Data::Dumper;

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
    my %tree = &process_data_direta($fh);
    $fh   = &check_file( $ARGV[2] );
    %tree = &process_data_transferencia( $fh, \%tree );
    
    my $migrate = CMD::Data::Migrate->new(
        rs => $rs,
        year => $year
    );
    
    %tree = $migrate->proccess_values(%tree);

    my $root = $rs->create( { content => $year, valor => 0 } );
    $migrate->hash_to_db( $root, \%tree );
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

        $valor = fix_valor($valor);

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

sub process_data_direta {
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
        $valor = fix_valor($valor);


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

