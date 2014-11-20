package Locale::Babelfish::Phrase::Node;

# ABSTRACT: Babelfish AST abstract node.

use utf8;
use strict;
use warnings;

use parent qw( Class::Accessor::Fast );

# VERSION

sub new {
    my ( $class, %args ) = @_;
    return bless { %args }, $class;
}

sub to_perl_escaped_str {
    my ( $self, $str ) = @_;

    $str =~ s/\\/\\\\/g;
    $str =~ s/'/\\'/g;
    return "'$str'";
}

1;
