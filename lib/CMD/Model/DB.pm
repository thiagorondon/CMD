package CMD::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CMD::Schema',

    connect_info => {
        dsn      => CMD->config->{ db_config }->{ dsn },
        user     => CMD->config->{ db_config }->{ user },
        password => CMD->config->{ db_config }->{ password },
    }
);

1;

