package Locale::Babelfish::Maketext;

=encoding utf-8

=head1 NAME

Locale::Babelfish::Maketext;

=head1 DESCRIPTION

Wrapper Locale::Maketext

=cut

use utf8;
use Modern::Perl;
use Carp;
use parent 'Locale::Maketext';

=head2 create_lh

    $class->create_lh( $dictname, $lang, $lex );

    Handler for dictionary at  Locale::Maketext

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

=head2 set_lexicon

    $self->set_lexicon( $lex );

=cut

sub set_lexicon {
    my ($self, $lex) = @_;
    no strict 'refs';
    %{ref($self)."::Lexicon"} = %$lex if ref $lex eq 'HASH';
}

=head2 lexicon

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

sub quant {
    my $self = shift;
    return $_[0] . ' ' . $self->quant_word(@_);
}

sub numb {
    my $self = shift;
    return  $self->quant_word(@_);
}


sub quant_word { die "Must be implemented" }


sub quant_word_std_single {
    my ($self, $num, $single) = @_;
    return $single;
}

sub quant_word_std_double {
    my ($self, $num, $single, $plural) = @_;
    return $num == 1 ? $single : ($plural || $single);
}


=head1 SEE ALSO

L<Locale::Maketext>, Lhttps://github.com/nodeca/babelfish

=head1 AUTHORS

Mironov Igor E<lt>mironov.igor@gmail.com<gt>
Crazy Panda LLC
REG.RU LLC

=head1 COPYRIGHT

This software is released under the MIT license cited below.  Additionally,
when this software is distributed with B<Perl Kit, Version 5>, you may also
redistribute it and/or modify it under the same terms as Perl itself.

=head2 The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

=cut

1;
