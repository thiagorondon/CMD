
package CMD::Schema::Period;

use strict;
use warnings;

use base qw( DBIx::Class );

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('period');
__PACKAGE__->add_columns(
    id    => { is_auto_increment => 1,         data_type   => 'integer' },
    year  => { data_type         => 'integer', is_nullable => 1 },
    month => { data_type         => 'integer', is_nullable => 1 },
    day   => { data_type         => 'integer', is_nullable => 1 }
);

__PACKAGE__->set_primary_key('id');

=head1 AUTHOR

Thiago Rondon, C<< <thiago.rondon at gmail.com> >>

=cut

1;

