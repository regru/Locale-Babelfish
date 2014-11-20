package Locale::Babelfish::Phrase::Variable;

# ABSTRACT: Babelfish AST Variable substitution node.

use utf8;
use strict;
use warnings;

# VERSION

use parent qw( Locale::Babelfish::Phrase::Node );

__PACKAGE__->mk_accessors( qw( name ) );

sub to_perl_escaped_str {
    my ( $self ) = @_;

    return $self->SUPER::to_perl_escaped_str( $self->name );
}

1;
