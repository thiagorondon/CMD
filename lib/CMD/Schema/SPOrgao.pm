
package CMD::Schema::SPOrgao;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('sp_orgao');
__PACKAGE__->add_columns(
    id     => { is_auto_increment => 1,         data_type   => 'integer' },
    codigo => { data_type         => 'varchar', is_nullable => 1, },
    nome   => { data_type         => 'varchar', is_nullable => 1, },
);

__PACKAGE__->set_primary_key('codigo');

__PACKAGE__->belongs_to(
    col => 'CMD::Schema::SP' => { 'foreign.orgao_id' => 'self.id' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

