# NAME

Locale::Babelfish - wrapper between Locale::Maketext::Lexicon and github://nodeca/babelfish format

# VERSION

version 0.02

# SYNOPSIS

    package Foo;
    use Locale::Babelfish;

    my $bf = Locale::Babelfish->new( { dirs => [ '/path/to/dictionaries'] } );
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );

More sophisticated example:

    package Foo::Bar;

    use Locale::Babelfish;
    ...
    my $bf = Locale::Babelfish->new( {
            dirs         => [ '/path/to/dictionaries'],
            default_lang => ['ru_RU'], # By default en_US
            langs        => [{ 'uk_UA' => 'Foo::Bar::Lang::uk_UA' } , 'de_DE' ] # for custom languages specify they are plural forms
        },
        $logger # Logger for example Log::Log4Perl, not required parameter
    );
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );
    $bf->set_context_lang('en_US');
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );

# DESCRIPTION

Internationalisation with easy syntax.
Simple wrapper between Locale::Maketext and https://github.com/nodeca/babelfish format.
Created for using same dictionaries on backend and frontend.

# METHODS

## set\_context\_lang

    $self->set_context_lang( 'ru_RU' );

    Setting current context.

## check\_dictionaries

    $self->check_dictionaries();

    check what changed at dictionaries

## t

    Get internationalized value for key from dictionary.

    $self->t( 'main.key.subkey' , { paaram1 => 1 , param2 => { next_level  => 'test' } } );
    Where main - is dictionary, key.subkey - key at dictionary

# Phrases Syntax

\#{varname} Echoes value of variable
((Singular|Plural1|Plural2)):count Plural form

Example:

I have #{count} ((nail|nails)):count

or short form

I have #{count} ((nail|nails))

# dictionary file example

Module support only yaml format.
create dictionary file like: dictionary.en\_US.yaml where dictionary - is name of dictionary and en\_US - his locale

profile: Profiel
  apps:
    forums:
      new\_topic: New topic
      last\_post:
            title : Last message
demo:
    apples: I have #{count} ((apple|apples))

# Custom plural forms

By default locale will be inherited from en\_US.
If you would like specify own, create module like this:
and implement quant\_word function.

.....
package Locale::Babelfish::Lang::uk\_UA;

use parent 'Locale::Babelfish::Maketext';
use strict;

sub quant\_word {
    my ($self, $num, $single, $plural1, $plural2) = @\_;

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
......

# Dictionary encoding

    Use any convinient encoding.

## has\_any\_value

    $self->has_any_value( 'main.key.subkey' );

    Check exist or not key in dictionary.
    Where main - is dictionary, key.subkey - key at dictionary

## maketext

    $self->maketext( 'dict', 'key' , $param1, ... $paramN );

# SEE ALSO

[Locale::Maketext::Lexicon](https://metacpan.org/pod/Locale::Maketext::Lexicon)

[https://github.com/nodeca/babelfish](https://github.com/nodeca/babelfish)

# AUTHORS

- Igor Mironov <grif@cpan.org>
- Crazy Panda LLC
- REG.RU LLC

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Igor Mironov.

This is free software, licensed under:

    The MIT (X11) License
