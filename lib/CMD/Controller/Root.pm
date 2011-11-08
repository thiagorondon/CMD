package CMD::Controller::Root;
use Moose;
use namespace::autoclean;
use Scalar::Util qw(looks_like_number);
use CMD::Utils qw(formata_real formata_valor formata_float bgcolor);
use CMD::Data::Utils qw(get_root_by_nodeid);

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head1 NAME

CMD::Controller::Root - Root Controller for CMD

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub base : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash->{current_model} = 'DB';

    # warning to add something in stash here, because json output.
}

sub root : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{bases} = $c->model('DB::Base');
    $c->res->redirect('/node/1');
}

sub faq : Chained('base') Args(0) {
}

sub contato : Chained('base') Args(0) {
}

sub todo : Chained('base') Args(0) {
}

sub node : Chained('base') Args(1) {
    my ( $self, $c, $node ) = @_;
    $c->stash->{node}     = $node;
    $c->stash->{objnode}  = $c->model('DB::Node')->find($node);
    $c->stash->{rootnode} = get_root_by_nodeid( $c->stash->{objnode} );
    $c->stash->{bases}    = $c->model('DB::Base');
}

sub programa : Chained('base') Args(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash->{bases} = $c->model('DB::Base');
    my $rs         = $c->model('DBUTF8::Node');
    my $collection = $rs->find($id) or $c->detach('/');
    my $tt         = '2010';                              #c->stash->{tt};

    my %yyout;
    foreach my $yy ( 2006 .. 2010 ) {
        $yyout{$yy} = $rs->search_rs(
            {
                codigo    => $collection->codigo,
                funcao    => $collection->funcao,
                subfuncao => $collection->subfuncao,
                ano       => $yy
            }
        )->get_column('valor')->sum;
    }

    my $total = $rs->search_rs(
        {
            codigo    => $collection->codigo,
            funcao    => $collection->funcao,
            subfuncao => $collection->subfuncao,
            ano       => $tt
        }
    )->get_column('valor')->sum;

    my $total_direto = $rs->search_rs(
        {
            codigo    => $collection->codigo,
            funcao    => $collection->funcao,
            subfuncao => $collection->subfuncao,
            estado    => undef,
            ano       => $tt
        }
    )->get_column('valor')->sum;

    my $total_repasse = $rs->search_rs(
        {
            codigo    => $collection->codigo,
            funcao    => $collection->funcao,
            subfuncao => $collection->subfuncao,
            estado    => { '!=', undef },
            ano       => $tt
        },

    )->get_column('valor')->sum;

    my $objs = $rs->search(
        {
            codigo    => $collection->codigo,
            funcao    => $collection->funcao,
            subfuncao => $collection->subfuncao,
            estado    => { '!=' => undef },
            ano       => $tt
        }
    );
    my %estado;

    foreach my $item ( $objs->all ) {
        next unless $item->valor or $item->estado;
        if ( grep( keys %estado, $item->estado ) ) {
            $estado{ $item->estado } += $item->valor;
        }
        else {
            $estado{ $item->estado } = $item->valor;
        }
    }
    my @estados;
    foreach my $item ( keys %estado ) {
        my $ufname = $item;
        my $pc     = $estado{$item} * 100 / $total;
        $pc = formata_float( $pc, 2 );

        #$ufname =~ s/([\w']+)/\u\L$1/g;
        push(
            @estados,
            {
                nome        => $ufname . " ($pc\%)",
                total       => $estado{$item},
                total_print => formata_real( $estado{$item} )
            }
        );
    }

    $c->stash(
        id                => $id,
        collection        => $collection,
        total             => formata_real($total),
        total_direto      => formata_real($total_direto),
        total_repasse     => formata_real($total_repasse),
        raw_total_direto  => $total_direto || 0,
        raw_total_repasse => $total_repasse || 0,
        raw_total         => $total || 0,
        estados           => [@estados],
        yyout             => \%yyout
    );
}

=head2 default

Standard 404 error page

=cut

sub error_404 : Chained('base') PathPart('') Args {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);
#    $c->res->redirect('/');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head1 AUTHOR

Thiago Rondon

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
