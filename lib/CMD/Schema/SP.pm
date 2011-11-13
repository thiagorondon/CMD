
package CMD::Schema::SP;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('sp');

__PACKAGE__->add_columns(
    id => { is_auto_increment => 1, data_type => 'integer' },

    orgao_id                => { data_type => 'integer' },
    unidade_orcamentaria_id => { data_type => 'integer' },
    unidade_gestora_id      => { data_type => 'integer' },
    categoria_despesa_id    => { data_type => 'integer' },
    grupo_despesa_id        => { data_type => 'integer' },
    funcao_id               => { data_type => 'integer' },
    subfuncao_id            => { data_type => 'integer' },
    credor_id               => { data_type => 'integer' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_one(
    orgao => 'CMD::Schema::SPOrgao' => { 'foreign.id' => 'self.orgao_id' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

