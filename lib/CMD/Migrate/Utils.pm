
package CMD::Migrate::Utils;

use utf8;
use strict;
use warnings;

use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT_FAIL);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw(fix_valor);
$VERSION    = "0.01";
$VERSION   = eval $VERSION;

sub fix_valor {
    my $v = shift;
    $v =~ s/\,/\./;
    $v =~ s/\'//g;
    $v =~ s/\n//;
    $v =~ s/\r//;
    return $v;
}

1;

