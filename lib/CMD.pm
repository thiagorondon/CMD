package CMD;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
  -Debug
  ConfigLoader
  Static::Simple
  /;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in cmd.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'CMD',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    default_view                                => 'TT',
    'View::TT'                                  => {
        INCLUDE_PATH =>
          [ map { __PACKAGE__->path_to(@$_) }[qw(root src)], [qw(root lib)] ]
    },
);

# Load database config:
__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'db_config.json' } );

# Start the application
__PACKAGE__->setup();

sub update_config_status {
    my ( $self, ) = @_;
    use JSON::XS;
    my $json = { };
    $json->{ db_config } = __PACKAGE__->config->{ db_config };
    $json->{ db_config }->{ install } = 'no'; #UPDATE INSTALL VAL
    my $json_text = encode_json( $json );
    open( FHOUT , '>', 'db_config.json' );
    print FHOUT $json_text;
    close FHOUT;
}

sub is_db_configured {
    my ( $self, $c ) = @_;
    warn "INICIANDO VERIFICACOES DE INSTALACAO DO BANCO DE DADOS";
    my $schema = CMD::Schema->connect(
        __PACKAGE__->config->{ db_config }->{ dsn },
        __PACKAGE__->config->{ db_config }->{ user },
        __PACKAGE__->config->{ db_config }->{ password },
    );
    my $database = eval { $schema->resultset( 'Node' )->search()->first; };
    if ( ! $database ) {
        if ( defined __PACKAGE__->config->{ db_config }->{ user }
         and defined __PACKAGE__->config->{ db_config }->{ password }
         and defined __PACKAGE__->config->{ db_config }->{ dsn }
            ) {
            warn "Tentarei criar as tabelas no banco " ;
            my $schema = CMD::Schema->connect(
                __PACKAGE__->config->{ db_config }->{ dsn },
                __PACKAGE__->config->{ db_config }->{ user },
                __PACKAGE__->config->{ db_config }->{ password },
            );
            $schema->deploy;
            my $cmd = "perl -Ilib raw2db/federal.pl 2010 data/raw/federal/diretas/2010.csv data/raw/federal/transferencia/2010.csv";
            warn "Iniciando instalacao do banco de dados.";
            warn `$cmd` . "\n\n"; 
            warn "dados inseridos no banco";
            $self->update_config_status();

            warn <<HELPADD

    Agora:

    1. Reinicie o servidor

HELPADD
            ;
        } else {
            #nao foi encontrado usuario e senha
            my $help = `cat ../INSTALL`;
            warn $help;
        }
    }
}

__PACKAGE__->is_db_configured();

=head1 NAME

CMD - Catalyst based application

=head1 SYNOPSIS

    script/cmd_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<CMD::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
