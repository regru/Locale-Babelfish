package Locale::Babelfish::Phrase::ParserBase;

# ABSTRACT: Babelfish abstract parser.

use utf8;
use strict;
use warnings;

use parent qw( Class::Accessor::Fast );

# VERSION

__PACKAGE__->mk_accessors( qw( phrase index length prev piece escape ) );

sub new {
    my ( $class, $phrase ) = @_;
    my $parser = bless {}, $class;
    $parser->init( $phrase )  if defined $phrase;
    return $parser;
}

sub init {
    my ( $self, $phrase ) = @_;
    $self->phrase( $phrase );
    $self->index( -1 );
    $self->prev( undef );
    $self->length( length( $phrase ) );
    $self->piece( '' );
    $self->escape( 0 );
    return $self;
}


sub trim {
    my ( $self, $str ) = @_;
    $str =~ s/\A\p{PerlSpace}+//;
    $str =~ s/\p{PerlSpace}+\z//;
    return $str;
}

sub char {
    my ( $self ) = @_;
    return substr( $self->phrase, $self->index, 1 ) // '';
}

sub next_char {
    my ( $self ) = @_;
    return ''  if $self->index >= $self->length - 1;
    return substr( $self->phrase, $self->index + 1, 1 ) // '';
}

sub to_next_char {
    my ( $self ) = @_;
    if ( $self->index >= 0 ) {
        $self->prev( $self->char );
    }
    $self->index( $self->index + 1 );
    return ''  if $self->index eq $self->length;
    return $self->char();
}

sub throw {
    my ( $self, $message ) = @_;
    die "Cannot parse phrase \"". ( $self->phrase // 'undef' ). "\" at ". ( $self->index // '-1' ). " index: $message";
}

sub add_to_piece {
    my ( $self, @chars ) = @_;
    $self->piece( join('', $self->piece, @chars ) );
}

sub backward {
    my ( $self ) = @_;
    $self->index( $self->index - 1 );
}

sub parse {
    my ( $self, $phrase ) = @_;

    if ( defined $phrase ) {
        $self->init( $phrase );
    }

    $self->throw( "No phrase given" )  unless defined $self->phrase;

    return $self->phrase;
}

1;
