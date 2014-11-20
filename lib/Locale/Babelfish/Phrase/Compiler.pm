package Locale::Babelfish::Phrase::Compiler;

use utf8;
use strict;
use warnings;

use List::Util 1.33 qw( none );

use Locale::Babelfish::Phrase::Literal ();
use Locale::Babelfish::Phrase::Variable ();
use Locale::Babelfish::Phrase::PluralForms ();

use parent qw( Class::Accessor::Fast );

__PACKAGE__->mk_accessors( qw( ast ) );

my $sub_index = 0;

sub new {
    my ( $class, $ast ) = @_;
    my $parser = bless {}, $class;
    $parser->init( $ast )  if $ast;
    return $parser;
}

sub init {
    my ( $self, $ast ) = @_;
    $self->ast( $ast );
    return $self;
}

sub throw {
    my ( $self, $message ) = @_;
    die "Cannot compile: $message";
}

sub concatenate_literals {
    my ( $self ) = @_;
    my $new_ast = [];
    my $prev = undef;
    for my $node ( @{ $self->ast } ) {
        if ( ref($node) eq 'SRX::L10N::Phrase::Literal' && ref($prev) eq ref($node) ) {
            $prev->text( $prev->text. $node->text );
            next;
        }
        $prev = $node;
        push @{ $new_ast }, $node;
    }

    $self->ast( $new_ast );

    return 1;
}

sub optimize {
    my ( $self ) = @_;
    $self->concatenate_literals;
}

sub compile {
    my ( $self, $ast ) = @_;

    $self->init( $ast )  if $ast;

    $self->throw("No AST given")  unless $self->ast;
    $self->throw("Empty AST given")  if scalar( @{ $self->ast } ) == 0;

    $self->optimize;

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
