package Locale::Babelfish::Phrase::Compiler;

# ABSTRACT: Babelfish AST Compiler

=head1 DESCRIPTION

Compiles AST to string or to coderef.

=cut

use utf8;
use strict;
use warnings;

use List::Util 1.33 qw( none );

use Locale::Babelfish::Phrase::Literal ();
use Locale::Babelfish::Phrase::Variable ();
use Locale::Babelfish::Phrase::PluralForms ();

use parent qw( Class::Accessor::Fast );

# VERSION

__PACKAGE__->mk_accessors( qw( ast ) );

my $sub_index = 0;

=method new

    $class->new()
    $class->new( $ast )

Instantiates AST compiler.

=cut

sub new {
    my ( $class, $ast ) = @_;
    my $parser = bless {}, $class;
    $parser->init( $ast )  if $ast;
    return $parser;
}

=method init

Initializes compiler. Should not be called directly.

=cut

sub init {
    my ( $self, $ast ) = @_;
    $self->ast( $ast );
    return $self;
}

=method throw

    $self->throw( $message )

Throws given message in compiler context.

=cut

sub throw {
    my ( $self, $message ) = @_;
    die "Cannot compile: $message";
}

=method compile

    $self->compile()
    $self->compile( $ast )

Compiles AST.

Result is string when possible; coderef otherwise.

=cut


sub compile {
    my ( $self, $ast ) = @_;

    $self->init( $ast )  if $ast;

    $self->throw("No AST given")  unless $self->ast;
    $self->throw("Empty AST given")  if scalar( @{ $self->ast } ) == 0;

    if ( scalar( @{ $self->ast } ) == 1 && ref($self->ast->[0]) eq 'Locale::Babelfish::Phrase::Literal' ) {
        #  просто строка
        return $self->ast->[0]->text;
    }

    my $text = 'sub { my ( $params ) = @_; return join \'\',';
    for my $node ( @{ $self->ast } ) {
        if ( ref($node) eq 'Locale::Babelfish::Phrase::Literal' ) {
            $text .= $node->to_perl_escaped_str. ',';
        }
        elsif ( ref($node) eq 'Locale::Babelfish::Phrase::Variable' ) {
            $text .= "(\$params->{". $node->to_perl_escaped_str. "} // ''),";
        }
        elsif ( ref($node) eq 'Locale::Babelfish::Phrase::PluralForms' ) {
            my $sub = $node->to_perl_sub();
            my $index = ++$sub_index;
            my $name = "Locale::Babelfish::Phrase::Compiler::COMPILED_SUB_$index";
            no strict 'refs';
            *{$name} = $sub;
            use strict 'refs';
            $text .= "$name(\$params),"
        }
    }
    $text .= '\'\'; }';
    return eval $text;
}

1;
