
package CMD::Schema::Credor;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('credores');
__PACKAGE__->add_columns(
    codigo => { data_type => 'varchar', is_nullable => 1,  },
    nome   => { data_type => 'varchar', is_nullable => 1,  },
);

__PACKAGE__->set_primary_key('codigo');

__PACKAGE__->has_many( cidade => 'CMD::Schema::Node' =>
      { 'foreign.credor_codigo' => 'self.codigo' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

