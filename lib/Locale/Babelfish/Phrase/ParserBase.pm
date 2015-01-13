package Locale::Babelfish::Phrase::ParserBase;

# ABSTRACT: Babelfish abstract parser.

use utf8;
use strict;
use warnings;

use parent qw( Class::Accessor::Fast );

# VERSION

__PACKAGE__->mk_accessors( qw( phrase index length prev piece escape ) );

=method new

    $class->new()
    $class->new( $phrase )

Instantiates parser.

=cut

sub new {
    my ( $class, $phrase ) = @_;
    my $parser = bless {}, $class;
    $parser->init( $phrase )  if defined $phrase;
    return $parser;
}

=method init

Initializes parser. Should not be called directly.

=cut

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

=method trim

    $self->trim( $str )

Removes space characters from start and end of specified string.

=cut

sub trim {
    my ( $self, $str ) = @_;
    $str =~ s/\A\p{PerlSpace}+//;
    $str =~ s/\p{PerlSpace}+\z//;
    return $str;
}

=method char

    $self->char

Gets character on current cursor position.

Will return empty string if no character.

=cut

sub char {
    my ( $self ) = @_;
    return substr( $self->phrase, $self->index, 1 ) // '';
}

=method next_char

    $self->next_char

Gets character on next cursor position.

Will return empty string if no character.

=cut

sub next_char {
    my ( $self ) = @_;
    return ''  if $self->index >= $self->length - 1;
    return substr( $self->phrase, $self->index + 1, 1 ) // '';
}

=method to_next_char

    $self->to_next_char

Moves cursor to next position.

Return new current character.

=cut

sub to_next_char {
    my ( $self ) = @_;
    if ( $self->index >= 0 ) {
        $self->prev( $self->char );
    }
    $self->index( $self->index + 1 );
    return ''  if $self->index eq $self->length;
    return $self->char();
}

=method throw

    $self->throw( $message )

Throws given message in phrase context.

=cut

sub throw {
    my ( $self, $message ) = @_;
    die "Cannot parse phrase \"". ( $self->phrase // 'undef' ). "\" at ". ( $self->index // '-1' ). " index: $message";
}

=method add_to_piece

    $parser->add_to_piece( @chars )

Adds given chars to current piece.

=cut

sub add_to_piece {
    my ( $self, @chars ) = @_;
    $self->piece( join('', $self->piece, @chars ) );
}

=method backward

    $parser->backward

Moves cursor backward.

=cut

sub backward {
    my ( $self ) = @_;
    $self->index( $self->index - 1 );
    if ( $self->index > 0 ) {
        $self->prev( substr( $self->phrase, $self->index - 1, 1 ) );
    }
    else {
        $self->prev( undef );
    }
}

=method parse

    $parser->parse()
    $parser->parse( $phrase )

Parses specified phrase.

=cut

sub parse {
    my ( $self, $phrase ) = @_;

    if ( defined $phrase ) {
        $self->init( $phrase );
    }

    $self->throw( "No phrase given" )  unless defined $self->phrase;

    return $self->phrase;
}

1;
