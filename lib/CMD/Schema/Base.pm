
package CMD::Schema::Base;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('bases');
__PACKAGE__->add_columns(
    id   => { is_auto_increment => 1, data_type => 'integer' },
    nome => { data_type         => 'varchar' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(
    bases_nodes => 'CMD::Schema::BaseNode' => { 'foreign.base_id' => 'self.id' }
);

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

