package Locale::Babelfish::Lang::en_US;

# ABSTRACT: en_US language

use parent 'Locale::Babelfish::Maketext';
use strict;

# VERSION

=for Pod::Coverage quant_word

=cut

sub quant_word { shift->quant_word_std_double(@_) }

1;
