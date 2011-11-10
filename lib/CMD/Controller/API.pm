package CMD::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

CMD::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base : Chained('/base') PathPart('api') CaptureArgs(0) {}

sub root : Chained('base') PathPart('') Args(0) {
  my ($self, $c) = @_;
  $c->response->body('api');
}

=head1 AUTHOR

Thiago Rondon

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
