
package CMD::Schema::Dataset;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('dataset');
__PACKAGE__->add_columns(
    id    => { is_auto_increment => 1,         data_type   => 'integer' },
    name  => { data_type         => 'varchar', is_nullable => 0, },
    table => { data_type         => 'varchar', is_nullable => 0, },
);

__PACKAGE__->set_primary_key('id');

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

