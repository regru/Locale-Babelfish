package Locale::Babelfish::Maketext;

# ABSTRACT: Wrapper around Locale::Maketext

use utf8;
use Modern::Perl;
use Carp;
use parent 'Locale::Maketext';

# VERSION

=method create_lh

Handler for dictionary at Locale::Maketext

    $class->create_lh( $dictname, $lang, $lex );

=cut

sub create_lh {
    my ( $class, $dictname, $lang, $lex, $parent ) = @_;

    $dictname =~ s/[^a-zA-Z0-9_]/_/g;
    my $gen_class = __PACKAGE__."::Dynamic::${dictname}::${lang}";

    $parent ||= "Locale::Babelfish::Lang::$lang";

    $parent = 'Locale::Babelfish::Lang::en_US' unless eval "require $parent;";

    unless ($gen_class->isa('Locale::Babelfish::Maketext')) {
        ## no critic
        eval "
            package $gen_class;
            use parent '$parent';
            use strict;
            our %Lexicon;
            1;
        ";
        die "Maketext: generation of dynamic class '$gen_class' failed: $@"
            if $@;
        eval "
            package ${gen_class}::".lc($lang).";
            use parent '$parent';
            use strict;
            our %Lexicon;
            1;
        ";
        die "Maketext: generation of dynamic class '${gen_class}::".lc($lang)."' failed: $@"
            if $@;
        ## use critic
    }

    my $lh = $gen_class->get_handle($lang);
    $lh->set_lexicon($lex);
    $lh->fail_with(sub {});
    return $lh;
}

=method set_lexicon

    $self->set_lexicon( $lex );

=cut

sub set_lexicon {
    my ($self, $lex) = @_;
    no strict 'refs';
    %{ref($self)."::Lexicon"} = %$lex if ref $lex eq 'HASH';
}

=method lexicon

    $self->lexicon();

=cut

sub lexicon {
    my $self = shift;
    no strict 'refs';
    return \%{ref($self)."::Lexicon"};
    use strict 'refs';
}


=head2 l10n

    $self->l10n( ... );

=cut

sub l10n { shift->maketext(@_) }

=for Pod::Coverage quant

=cut

sub quant {
    my $self = shift;
    return $_[0] . ' ' . $self->quant_word(@_);
}

=for Pod::Coverage numb

=cut

sub numb {
    my $self = shift;
    return  $self->quant_word(@_);
}

=for Pod::Coverage quant_word

=cut

sub quant_word { die "Must be implemented" }

=for Pod::Coverage quant_word_std_single

=cut

sub quant_word_std_single {
    my ($self, $num, $single) = @_;
    return $single;
}

=for Pod::Coverage quant_word_std_double

=cut

sub quant_word_std_double {
    my ($self, $num, $single, $plural) = @_;
    $num ||= 0;
    return $num == 1 ? $single : ($plural || $single);
}

=head1 SEE ALSO

L<Locale::Maketext>

L<https://github.com/nodeca/babelfish>

=cut

1;
