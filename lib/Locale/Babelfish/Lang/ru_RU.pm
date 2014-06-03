package Locale::Babelfish::Lang::ru_RU;

# ABSTRACT: ru_RU language

use parent 'Locale::Babelfish::Maketext';
use strict;

# VERSION

=for Pod::Coverage quant_word

=cut

sub quant_word {
    my ($self, $num, $single, $plural1, $plural2) = @_;
    my $num_s   = $num % 10;
    my $num_dec = $num % 100;
    my $ret;
    if    ($num_dec >= 10 and $num_dec <= 20) { $ret = $plural2 || $plural1 || $single }
    elsif ($num_s == 1)                       { $ret = $single }
    elsif ($num_s >= 2 and $num_s <= 4)       { $ret = $plural1 || $single }
    else                                      { $ret = $plural2 || $plural1 || $single }
    return $ret;
}

1;
