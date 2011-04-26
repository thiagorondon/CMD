package CMD::Model::2010;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CMD::Schema',

    connect_info => {
        dsn      => 'dbi:SQLite:dbname=' . CMD->path_to('data', '2010.db'),
        user     => '',
        password => '',
    }
);

1;

