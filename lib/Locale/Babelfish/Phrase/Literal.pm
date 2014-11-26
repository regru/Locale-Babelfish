package Locale::Babelfish::Phrase::Literal;

# ABSTRACT: Babelfish AST Literal node.

use utf8;
use strict;
use warnings;

use Locale::Babelfish::Phrase::Pluralizer ();

use parent qw( Locale::Babelfish::Phrase::Node );

# VERSION

__PACKAGE__->mk_accessors( qw( text ) );

=method to_perl_escaped_str

    $str = $node->to_perl_escaped_str

Returns node string to be used in Perl source code.

=cut

sub to_perl_escaped_str {
    my ( $self ) = @_;

    return $self->SUPER::to_perl_escaped_str( $self->text );
}

1;
