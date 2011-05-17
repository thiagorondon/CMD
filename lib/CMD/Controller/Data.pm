package CMD::Controller::Data;
use Moose;
use namespace::autoclean;
use Scalar::Util qw(looks_like_number);
use CMD::Utils qw(formata_real formata_valor formata_float bgcolor);
use CMD::Data::Utils qw(get_root_by_nodeid);
BEGIN { extends 'Catalyst::Controller' }

sub base : Chained('/base') PathPart('data') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    delete $c->stash->{current_model};
}

sub base2nodes : Chained('base') Args(1) {
    my ( $self, $c, $base ) = @_;
    my $objs = $c->model('DB::BaseNode')->search( { base_id => $base } );
    my @data;
    map {
        push( @data, { value => $_->node_id, display => $_->node->content } )
    } $objs->all;
    $c->stash->{data} = [@data];
    $c->forward('View::JSON');
}

sub node2base : Chained('base') Args(1) {
    my ( $self, $c, $node ) = @_;
    my $sc = $c->model('DB::Node')->find( { node_id => $node } );
    my $root = get_root_by_nodeid($sc);
    my $obj = $c->model('DB::BaseNode')->search( { node_id => $root->id } )->first;
    $c->stash->{data} = { base_id => $obj->base_id } if $obj;
    $c->forward('View::JSON');
}


sub node : Chained('base') Args(1) {
    my ( $self, $c, $id ) = @_;
    my $rs = $c->model('DB::Node');
    my $tree = $c->stash->{tree} = $rs->search( { parent_id => $id } );
    my $total = 0;
    map {
        $total += $_->valor
          if looks_like_number( $_->valor )
              and $_->content ne 'total'
    } $tree->all;
    $c->stash->{total_collection} = $total;
    $c->forward('handle_TREE');
}

sub handle_TREE : Private {
    my ( $self, $c ) = @_;

    my $tree             = $c->stash->{tree};
    my $tt               = $c->stash->{tt};
    my $total_collection = $c->stash->{total_collection};

    # I don't want this in JSON output.
    delete $c->stash->{collection};
    delete $c->stash->{tree};
    delete $c->stash->{tt};
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
            push( @zones, $parent[0]->content ) if scalar @parent;
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
            my $valor_porcentagem = $item->valor * 100 / $total;
            my $color             = shift(@bgcolor) || $bgcolor_default;
            my $valor_print       = formata_valor( $item->valor );
            my $porcentagem       = formata_float( $valor_porcentagem, 3 );
            my $zone              = $item->children->count ? '/node' : '/programa';
            my $link              = join( '/', $zone, $item->id );

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
                        valor_tabela    => formata_real( $item->valor ),
                        link            => $link,

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
    $c->stash->{zones} = join( ', ', @zones ) if @zones;
    warn $c->stash->{zones};
    $c->stash->{children} = [@children];

    #$c->stash->{levels}   = [@levels];
    $c->forward('View::JSON');
}

__PACKAGE__->meta->make_immutable;

1;
