package Locale::Babelfish::Phrase::Literal;

use utf8;
use strict;
use warnings;

use Locale::Babelfish::Phrase::Pluralizer ();

use parent qw( Locale::Babelfish::Phrase::Node );

__PACKAGE__->mk_accessors( qw( text ) );

sub to_perl_escaped_str {
    my ( $self ) = @_;

    return $self->SUPER::to_perl_escaped_str( $self->text );
}

1;
