package CMD::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CMD::Schema',

    connect_info => {
        dsn      => 'dbi:mysql:db=cmd',
        user     => 'cmd',
        password => 'aviao',
    }
);

1;

