
package CMD::Schema;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_classes;

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

