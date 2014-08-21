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
use Config::Any;

use constant LINES => 10000;
use constant COD_MUNICIPIO_EXTERIOR => 20000;

my $config = Config::Any->load_files( { files => [ "$Bin/../db_config.json" ], use_ext => 5 } );
if ( ! $config ) {
    warn "Arquivo de configuracao 'db_config.json' nao encontrado.";
    warn "leia o arquivo INSTALL para mais informacoes.";
    return 0;
}

my $schema = CMD::Schema->connect(
    $config->[0]{ "$Bin/../db_config.json" }->{ db_config }->{ dsn }, 
    $config->[0]{ "$Bin/../db_config.json" }->{ db_config }->{ user },
    $config->[0]{ "$Bin/../db_config.json" }->{ db_config }->{ password }, 
);
my $rs = $schema->resultset('Node');
my $rs_cidade = $schema->resultset('Cidade');
my $rs_bn = $schema->resultset('BaseNode');
my $rs_base = $schema->resultset('Base');

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
        rs_cidade => $rs_cidade,
        year => $year
    );
    
    %tree = $migrate->proccess_values(%tree);

    $rs_cidade->update_or_create({
        codigo => 0,
    });

    my $root = $rs->create( { content => $year, valor => 0, cidade_codigo => 0 } );
    my $hash_count = $migrate->hash_to_db( $root, \%tree );
    warn 'hash_to_db, count = '.$hash_count;

    my $base = $rs_base->update_or_create({
       nome => 'Governo Federal' 
    });

    $rs_bn->create({
        node_id => $root->node_id,
        base_id => $base->id
    });
}

sub process_data_transferencia {
    my ($fh, $treeref) = @_;
    my %tree = %$treeref;
    my $header = 0;
    my $counter = 0;
    while ( my $row = <$fh> ) {
        if(! $header) {
            $header++;
            next;
        }
        my @cols = split( /\;/, $row );
        map { $_ =~ s/\"//g; } @cols;
        my $valor = $cols[12];
        next unless $valor;
        my ($estado, $codmunicipio, $municipio, $codfuncao, $funcao, $codsubfuncao, $subfuncao, $codprograma, $programa) = @cols;

        $counter++;
        if($counter % LINES == 0) { warn "process_data_transferencia: count = ".$counter; }

        if(! looks_like_number($codmunicipio)) {
            warn 'does not look like number: transf/$codmunicipio = "'.$codmunicipio.'" -> '.COD_MUNICIPIO_EXTERIOR;
            $codmunicipio = COD_MUNICIPIO_EXTERIOR; # "Ext_" - Exterior
            #next;
        }

        $valor = fix_valor($valor);

        if (!defined($tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa})) {
            $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa} = "0-";
        }

        my ($last_valor) = split('-', $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa});

        return %tree unless looks_like_number($valor);
        $last_valor += $valor;

        $tree{$funcao}{$subfuncao}{'repasse'}{$estado}{$municipio}{$programa} =
"$last_valor-$codprograma-$codsubfuncao-$codfuncao-$estado-$codmunicipio-$municipio";
    }
    warn "process_data_transferencia:fim count = ".$counter;
    return %tree;
}

sub process_data_direta {
    my $fh = shift;
    my %tree;
    my $header = 0;
    my $counter = 0;
    while ( my $row = <$fh> ) {
        if(! $header) {
            $header++;
            next;
        }
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
        return %tree unless looks_like_number($valor);
        $last_valor += $valor;

        $tree{$funcao}{$subfuncao}{$programa} =
          "$last_valor-$codprograma-$codsubfuncao-$codfuncao";

        $counter++;
        if($counter % LINES == 0) { warn "process_data_direta: count = ".$counter; }
    }
    warn "process_data_direta:fim count = ".$counter;
    return %tree;
}

