package Locale::Babelfish::Phrase::Node;

# ABSTRACT: Babelfish AST abstract node.

use utf8;
use strict;
use warnings;

use parent qw( Class::Accessor::Fast );

# VERSION

=method new

    $class->new( %args )

Instantiates AST node.

=cut

sub new {
    my ( $class, %args ) = @_;
    return bless { %args }, $class;
}

=method to_perl_escaped_str

    $str = $node->to_perl_escaped_str

Returns node string to be used in Perl source code.

=cut

sub to_perl_escaped_str {
    my ( $self, $str ) = @_;

    $str =~ s/\\/\\\\/g;
    $str =~ s/'/\\'/g;
    return "'$str'";
}

1;
