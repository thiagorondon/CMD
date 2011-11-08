
package CMD::Schema::Node;

use strict;
use warnings;
use Config::Any;


use base qw( DBIx::Class );
my $config = Config::Any->load_files( { files => [ 'db_config.json' ], use_ext => 5 } );
#use Data::Dumper;
#warn Dumper $config;

__PACKAGE__->load_components(qw/Tree::AdjacencyList PK::Auto Core/);
__PACKAGE__->table('nodes');
__PACKAGE__->add_columns(
    node_id   => { is_auto_increment => 1, data_type => 'integer' },
    parent_id => { data_type         => 'integer', is_nullable => 1,  },
    position  => { data_type         => 'integer', is_nullable => 1,  },
    lft       => { data_type         => 'integer', is_nullable => 1,  },
    rgt       => { data_type         => 'integer', is_nullable => 1,  },
    content   => { data_type         => 'varchar', is_nullable => 1,  },
    valor     => { data_type         => 'double', is_nullable => 1,  },
    codigo    => { data_type         => 'varchar', is_nullable => 1,  },
    funcao    => { data_type         => 'varchar', is_nullable => 1,  },
    subfuncao => { data_type         => 'varchar', is_nullable => 1,  },
    cidade_codigo => { data_type => 'integer', is_nullable => 1,  },
    #credor_codigo => { data_type => 'varchar' },

    # TODO: Estado in a new table ?
    estado => { data_type => 'varchar', is_nullable => 1 },

    # TODO: tt_ini/tt_fim
    ano => { data_type => 'int', is_nullable => 1,  },
);

__PACKAGE__->set_primary_key('node_id');

__PACKAGE__->parent_column('parent_id') if ( 
    $config->[0]{ 'db_config.json' }->{ db_config }->{ install } ne 'yes'
);
__PACKAGE__->repair_tree(1) if (
    $config->[0]{ 'db_config.json' }->{ db_config }->{ install } ne 'yes'
);

__PACKAGE__->has_one( bases_nodes => 'CMD::Schema::BaseNode' =>
      { 'foreign.node_id' => 'self.node_id' } );

__PACKAGE__->belongs_to( cidade => 'CMD::Schema::Cidade' =>
      { 'foreign.codigo' => 'self.cidade_codigo' } );

#__PACKAGE__->belongs_to( credor => 'CMD::Schema::Credor' =>
#      { 'foreign.codigo' => 'self.credor_codigo' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

