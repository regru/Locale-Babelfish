package Locale::Babelfish::Phrase::PluralFormsParser;

# ABSTRACT: Babelfish plurals syntax parser.

use utf8;
use strict;
use warnings;
use feature 'state';

use Locale::Babelfish::Phrase::Parser ();

=head1 DESCRIPTION

Returns { script_forms => {}, regular_forms = [] }

Every plural form represented as AST.

=cut

# VERSION

use parent qw( Class::Accessor::Fast );

__PACKAGE__->mk_accessors( qw( phrase strict_forms regular_forms ) );

sub new {
    my ( $class, $phrase ) = @_;
    my $parser = bless {}, $class;
    $parser->init( $phrase )  if defined $phrase;
    return $parser;
}

sub init {
    my ( $self, $phrase ) = @_;
    $self->phrase( $phrase );
    $self->regular_forms( [] );
    $self->strict_forms( {} );
    return $self;
}

sub parse {
    my ( $self, $phrase ) = @_;

    $self->init( $phrase )  if defined $phrase;
    state $phrase_parser = Locale::Babelfish::Phrase::Parser->new();

    # тут проще регуляркой
    my @forms = split( m/(?<!\\)\|/s, $phrase );

    for my $form ( @forms ) {
        my $value = undef;
        if ( $form =~ m/\A=([0-9]+)\p{PerlSpace}*(.+)\z/s ) {
            ( $value, $form ) = ( $1, $2 );
        }
        $form = $phrase_parser->parse( $form );

        if ( defined $value ) {
            $self->strict_forms->{$value} = $form;
        }
        else {
            push @{ $self->regular_forms }, $form;
        }
    }

    return {
        strict => $self->strict_forms,
        regular => $self->regular_forms,
    };
}

1;
