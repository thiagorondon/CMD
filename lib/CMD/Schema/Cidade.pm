
package CMD::Schema::Cidade;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('cidades');
__PACKAGE__->add_columns(
    codigo => { data_type => 'integer' },
    nome   => { data_type => 'varchar' },
    estado => { data_type => 'varchar' }
);

__PACKAGE__->set_primary_key('codigo');

__PACKAGE__->has_many( cidade => 'CMD::Schema::Node' =>
      { 'foreign.cidade_codigo' => 'self.codigo' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

