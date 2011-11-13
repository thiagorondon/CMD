
package CMD::Schema::Root;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/PK::Auto Core Tree::AdjacencyList/);
__PACKAGE__->table('root');
__PACKAGE__->add_columns(
    id        => { is_auto_increment => 1,         data_type   => 'integer' },
    parent_id => { data_type         => 'integer', is_nullable => 1, },

    dataset_id => { data_type => 'integer' },
    period_id  => { data_type => 'integer' },
    valor      => { data_type => 'float' }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->parent_column('parent_id');

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

