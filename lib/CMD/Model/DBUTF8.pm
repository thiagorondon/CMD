package CMD::Model::DBUTF8;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CMD::Schema',

    connect_info => {
        dsn           => 'dbi:mysql:db=cmd',
        user          => 'cmd',
        password      => 'aviao',
        on_connect_do => ['set names utf8']
    }
);

1;
