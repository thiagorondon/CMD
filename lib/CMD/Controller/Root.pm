package CMD::Controller::Root;
use Moose;
use namespace::autoclean;
use Scalar::Util qw(looks_like_number);
use CMD::Utils qw(formata_real formata_valor formata_float bgcolor);

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
}

sub root : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
    $c->res->redirect('/year/2010');    # hard coding.
}

sub year : Chained('base') Args(1) {
    my ( $self, $c, $year ) = @_;

    $c->stash(
        year     => $year,
        template => 'root.tt'
    );
}

sub faq : Chained('base') Args(0) {
}

sub contato : Chained('base') Args(0) {
}

sub todo : Chained('base') Args(0) {
}

sub collection : Chained('base') CaptureArgs(1) {
    my ( $self, $c, $year ) = @_;
    my $rs = $c->model( 'DB::Node' );

    $c->detach unless $rs;
    my $obj = $rs->search( { content => $year } )->first;
    my $tree = $rs->search({ parent_id => $obj->id });
    my $total = 0;
    map {
        $total += $_->valor
          if looks_like_number( $_->valor )
              and $_->content ne 'total'
    } $tree->all;

    $c->stash(
        collection       => $rs,
        year             => $year,
        total_collection => $total,
    );
}

sub collection_root : Chained('collection') PathPart('root') Args(0) {
    my ( $self, $c ) = @_;
    my $rs = $c->stash->{collection};
    my $obj = $rs->search( { content => $c->stash->{year} } )->first;
    $c->stash->{tree} = $rs->search( { parent_id => $obj->id } );
    $c->forward('handle_TREE');
}

sub collection_node : Chained('collection') PathPart('node') Args(1) {
    my ( $self, $c, $id ) = @_;
    my $rs = $c->stash->{collection};
    $c->stash->{tree} = $rs->search( { parent_id => $id } );
    $c->forward('handle_TREE');
}

sub node : Chained('base') Args(2) {
    my ( $self, $c, $year, $node ) = @_;
    $c->stash(
        year     => $year,
        node     => $node,
        template => 'root.tt'
    );
}

sub prog : Chained('base') Args(2) {
    my ( $self, $c,  $year, $id ) = @_;
    my $rs = $c->model( 'DBUTF8::Node');
    my $collection = $rs->find( $id ) or $c->detach('/');

    my %yyout;
    foreach my $yy (2006 .. 2010) {
        $yyout{$yy} =
        $rs->search_rs({ codigo => $collection->codigo,
        funcao => $collection->funcao, subfuncao => $collection->subfuncao,
        year => $yy })->get_column('valor')->sum;
    }

    my $total = $rs->search_rs({ codigo => $collection->codigo,
        funcao => $collection->funcao, subfuncao => $collection->subfuncao,
        year => $year
    })
        ->get_column('valor')->sum;

    my $total_direto = $rs->search_rs({ codigo => $collection->codigo, 
        funcao => $collection->funcao, subfuncao => $collection->subfuncao,
        estado => undef,
        year => $year
        })->get_column('valor')->sum;

    my $total_repasse = $rs->search_rs({ codigo => $collection->codigo,
        funcao => $collection->funcao, subfuncao => $collection->subfuncao,
        estado => { '!=', undef },
        year => $year
        },
        
        )->get_column('valor')->sum;

    my $objs = $rs->search({ codigo => $collection->codigo,
        funcao => $collection->funcao, subfuncao => $collection->subfuncao,
        estado => { '!=' => undef },
        year => $year
        });
    my %estado;

    foreach my $item ($objs->all) {
        next unless $item->valor or $item->estado;
        if ( grep(keys %estado, $item->estado) ) {
            $estado{$item->estado} += $item->valor;
        } else {
            $estado{$item->estado} = $item->valor;
        }
    }
    my @estados;
    foreach my $item (keys %estado) {
        my $ufname = $item;
        my $pc = $estado{$item} * 100 / $total; 
        $pc = formata_float($pc, 2);
        #$ufname =~ s/([\w']+)/\u\L$1/g;
        push(@estados, { 
            nome => $ufname . " ($pc\%)", 
            total => $estado{$item}, 
            total_print => formata_real($estado{$item}) } );
    }

    $c->stash(
        year        => $year,
        id          => $id,
        collection    => $collection,
        total => formata_real($total),
        total_direto => formata_real($total_direto),
        total_repasse => formata_real($total_repasse),
        raw_total_direto => $total_direto || 0,
        raw_total_repasse => $total_repasse || 0,
        estados => [ @estados ],
        yyout => \%yyout
    );
}

sub handle_TREE : Private {
    my ( $self, $c ) = @_;

    my $imposto          = $c->req->query_parameters->{imposto} || 1000;
    my $tree             = $c->stash->{tree};
    my $year             = $c->stash->{year};
    my $total_collection = $c->stash->{total_collection};

    # I don't want this in JSON output.
    delete $c->stash->{collection};
    delete $c->stash->{tree};
    delete $c->stash->{year};
    delete $c->stash->{total_collection};

    my @levels;
    my @children;
    my @zones;
    my @bgcolor         = bgcolor;
    my $bgcolor_default = '#c51d18';    # in config file ?

    if ($tree) {
        # zones
        my $point = $tree->first;
        while ($point) { 
            my @parent = $point->parents();
            push(@zones, $parent[0]->content) if scalar @parent;
            $point = $point->parent;
        }

        # % by zone.
        my $total = 0;
        map {
            $total += $_->valor
              if looks_like_number( $_->valor )
                  and $_->content ne 'total'
        } $tree->all;
        $c->stash->{total_tree} = formata_real( $total, 2 );

        # Make tree for openspending javascript.
        map {
            my $item              = $_;
            my $valor_usuario     = $item->valor * $imposto / $total_collection;
            my $valor_porcentagem = $item->valor * 100 / $total;
            my $color             = shift(@bgcolor) || $bgcolor_default;
            my $valor_print       = formata_valor( $item->valor );
            my $porcentagem       = formata_float( $valor_porcentagem, 3 );
            my $zone              = $item->children->count ? '/node' : '/prog';
            my $link              = join( '/', $zone, $year, $item->id );

            #push( @levels, $item->level ) unless grep ( $item->level, @levels );

            # Fix content with 'repasse' in db. Fix DB ?
            my $title =
              $item->content eq 'repasse'
              ? 'Repasse para estados e mun&iacute;cipios'
              : $item->content;
            #$title =~ s/([\w']+)/\u\L$1/g;

            push(
                @children,
                {
                    data => {
                        title           => $title,
                        '$area'         => $porcentagem,
                        '$color'        => $color,
                        value           => $porcentagem,
                        printable_value => $valor_print,
                        porcentagem     => $porcentagem,
                        valor_usuario   => formata_real( $valor_usuario, 4 ),
                        valor_tabela    => formata_real( $item->valor ),
                        link => $link ,

                        ( $valor_porcentagem > 3 )
                        ? ( show_title => 'true' )
                        : (),

                    },
                    children => [],
                    name     => $title,
                    id       => $item->id,

                }
              )
              if $item->valor
        } $tree->all;
    }

    # here, we go.
    @zones = reverse(@zones);
    shift(@zones);
    $c->stash->{zones} = join(', ', @zones) if @zones;
    warn $c->stash->{zones};
    $c->stash->{children} = [@children];
    #$c->stash->{levels}   = [@levels];
    $c->forward('View::JSON');
}

=head2 default

Standard 404 error page

=cut

sub error_404 : Chained('base') PathPart('') Args {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);
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
