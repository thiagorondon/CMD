
package CMD::Schema;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_classes;

sub connect_test {
    my ( $self, $db_file, $dump_sql ) = @_;

    unlink($db_file) if -e $db_file;
    unlink( $db_file . '-journal' ) if -e $db_file . '-journal';
    mkdir("t/var") unless -d "t/var";

    my $dsn    = "dbi:SQLite:$db_file";
    my $schema = $self->connect($dsn);

    $schema->storage->on_connect_do( ["PRAGMA synchronous = OFF"] );
    my $dbh = $schema->storage->dbh;
    open SQL, $dump_sql;
    my $sql;
    { local $/ = undef; $sql = <SQL>; }
    close SQL;
    $dbh->do($_) for split( /\n\n/, $sql );

    $schema->storage->dbh->do("PRAGMA synchronous = OFF");

    return $schema;

}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

