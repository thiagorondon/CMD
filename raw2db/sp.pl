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
use Text::CSV;

my $schema = CMD::Schema->connect( "dbi:mysql:db=cmd", "cmd", "aviao" );
my $rs = $schema->resultset('Node');
my $rs_cidade = $schema->resultset('Cidade');
my $year;

&main;

sub check_file {
    my $filename = shift;
    open my $fh, '<', $filename or die "error: $@ \n";
    return $fh;
}

sub main {

    if (!$ARGV[1]) {
        print "Use: ./script.pl ano gastos.csv\n";
        exit 0;
    }

    $year = $ARGV[0];
    my $fh   = &check_file( $ARGV[1] );
    my %tree = &process_data($fh);
    
    my $migrate = CMD::Data::Migrate->new(
        rs => $rs,
        rs_cidade => $rs_cidade,
        year => $year
    );
    
    %tree = $migrate->proccess_values(%tree);

    $rs_cidade->update_or_create({
        codigo => 0,
    });

    my $root = $rs->create( { content => $year, valor => 0, cidade_codigo => 0 } );
    $migrate->hash_to_db( $root, \%tree );
}

sub process_data {
    my $fh = shift;
    my %tree;
    my $header = 0;
    my $csv = Text::CSV->new();

    while ( my $row = <$fh> ) {
#        my $status  = $csv->parse($row);       
#        my @cols = $csv->fields();
         my @cols = split(/\"\,\"/, $row);
#my @cols = split( /\,/, $row );

        next if $cols[0] eq 'ANO DE REFERENCIA';
        next unless $cols[0];
        next unless $cols[17];

        my $valor        = $cols[34];
        my $codfuncao    = $cols[17];
        my $funcao       = $cols[18];
        my $codsubfuncao = $cols[19];
        my $subfuncao    = $cols[20];
        my $codprograma  = $cols[21];
        my $programa     = $cols[22];
        $valor = fix_valor($valor);
        
        $codfuncao =~ s/\"//g;
        $funcao =~ s/\"//g;
        $codsubfuncao =~ s/\"//g;
        $subfuncao =~ s/\"//g;
        $codprograma =~ s/\"//g;
        $programa =~ s/\"//g;
        $valor =~ s/\"//g;
        next if !$valor;

#        print "
#            funcao: $funcao
#            codfuncao: $codfuncao
#            subfuncao: $subfuncao
#            codsubfuncao: $codsubfuncao
#            programa: $programa
#            codprograma: $codprograma
#            valor: $valor
#        ";


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

