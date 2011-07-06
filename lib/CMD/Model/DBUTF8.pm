package CMD::Model::DBUTF8;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CMD::Schema',

    connect_info => {
        dsn      => __PACKAGE__->config->{ db_config }->{ dsn },
        user     => __PACKAGE__->config->{ db_config }->{ username },
        password => __PACKAGE__->config->{ db_config }->{ password },
        on_connect_do => ['set names utf8']
    }
);

1;
