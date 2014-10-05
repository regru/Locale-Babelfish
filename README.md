# NAME

Locale::Babelfish - wrapper between Locale::Maketext::Lexicon and github://nodeca/babelfish format

# VERSION

version 0.06

# SYNOPSIS

    package Foo;
    use Locale::Babelfish;

    my $bf = Locale::Babelfish->new( { dirs => [ '/path/to/dictionaries' ] } );
    print $bf->t('dictionary.firstkey.nextkey', { foo => 'bar' } );

More sophisticated example:

    package Foo::Bar;
    use Locale::Babelfish;
    my $bf = Locale::Babelfish->new(
        # configuration
        {
            dirs         => [ '/path/to/dictionaries' ],
            default_lang => [ 'ru_RU' ], # By default en_US
            langs        => [
                { 'uk_UA' => 'Foo::Bar::Lang::uk_UA' },
                'de_DE',
            ], # for custom languages specify they are plural forms
        },
        # logger, for example Log::Log4Perl (not required parameter)
        $logger
    );

    # use default language
    print $bf->t('dictionary.firstkey.nextkey', { foo => 'bar' } );

    # switch language
    $bf->set_locale('en_US');
    print $bf->t('dictionary.firstkey.nextkey', { foo => 'bar' } );

    # Get current locale
    print $bf->current_locale;

# DESCRIPTION

Internationalisation with easy syntax. Simple wrapper between [Locale::Maketext](https://metacpan.org/pod/Locale::Maketext) and
[https://github.com/nodeca/babelfish](https://github.com/nodeca/babelfish) format. Created for using same dictionaries on backend and
frontend.

# METHODS

## new

Constructor

    my $bf = Locale::Babelfish->new( {
                            dirs => [ '/path/to/dictionaries' ], # is required
                            suffix => 'yaml', # dictionaries extension
                            default_lang => 'ru_RU', # by default en_US
                            langs => [ 'de_DE', 'fr_FR', 'uk_UA' => 'Foo::Bar::Lang::uk_UA' ]
                        }, $logger  );

## set\_locale

Setting current locale.

    $self->set_locale( 'ru_RU' );

## set\_context\_lang

depricated, please use set\_locale

    $self->set_context_lang( 'ru_RU' );

## check\_dictionaries

Check what changed at dictionaries. And renew dictionary content without restart.

    $self->check_dictionaries();

## t\_or\_undef

Get internationalized value for key from dictionary.

    $self->t_or_undef( 'main.key.subkey' , { param1 => 1 , param2 => { next_level  => 'test' } } );

Where `main` - is dictionary, `key.subkey` - key at dictionary.

## t

Get internationalized value for key from dictionary.

    $self->t( 'main.key.subkey' , { param1 => 1 , param2 => { next_level  => 'test' } } );

Where `main` - is dictionary, `key.subkey` - key at dictionary.

## has\_any\_value

Check exist or not key in dictionary.

    $self->has_any_value( 'main.key.subkey' );

Where `main` - is dictionary, `key.subkey` - key at dictionary.

## maketext

same as t, but parameters for substitute are sequential

    $self->maketext( 'dict', 'key.subkey ' , $param1, ... $paramN );

Where `dict` - is dictionary, `key.subkey` - key at dictionary.

# DICTIONARIES

## Phrases Syntax

\#{varname} Echoes value of variable
((Singular|Plural1|Plural2)):count Plural form

Example:

    I have #{count} ((nail|nails)):count

or short form

    I have #{count} ((nail|nails))

## Dictionary file example

Module support only YAML format. Create dictionary file like: **dictionary.en\_US.yaml** where
`dictionary` is name of dictionary and `en_US` - its locale.

    profile: Profiel
        apps:
            forums:
                new_topic: New topic
                last_post:
                    title : Last message
    demo:
        apples: I have #{count} ((apple|apples))

## Custom plural forms

By default locale will be inherited from `en_US`. If you would like specify own, create module like
this and implement **quant\_word** function.

    package Locale::Babelfish::Lang::uk_UA;

    use strict;
    use parent 'Locale::Babelfish::Maketext';

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

## Encoding

Use any convinient encoding. But better use utf8 with BOM.

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
