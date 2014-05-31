package Locale::Babelfish::Lang::en_US;

use parent 'Locale::Babelfish::Maketext';
use strict;

sub quant_word { shift->quant_word_std_double(@_) }

1;
