
package CMD::Schema::BaseNode;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('bases_nodes');
__PACKAGE__->add_columns(
    base_id => { data_type => 'integer' },
    node_id => { data_type => 'integer' }
);

__PACKAGE__->set_primary_key(qw(base_id node_id));

__PACKAGE__->belongs_to(
    base => 'CMD::Schema::Base' => { 'foreign.id' => 'self.base_id' } );

__PACKAGE__->belongs_to(
    node => 'CMD::Schema::Node' => { 'foreign.node_id' => 'self.node_id' } );

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

