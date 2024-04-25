# NAME

Locale::Babelfish - Perl I18n using https://github.com/nodeca/babelfish format.

[![Build Status](https://travis-ci.org/regru/Locale-Babelfish.svg?branch=master)](https://travis-ci.org/regru/Locale-Babelfish)

# VERSION

version 2.13

# DESCRIPTION

Библиотека локализации.

# NAME

Locale::Babelfish

# SYNOPSYS

    package Foo;

    use Locale::Babelfish ();

    my $bf = Locale::Babelfish->new( { dirs => [ '/path/to/dictionaries' ] } );
    print $bf->t('dictionary.firstkey.nextkey', { foo => 'bar' } );

More sophisticated example:

    package Foo::Bar;

    use Locale::Babelfish ();

    my $bf = Locale::Babelfish->new( {
        # configuration
        dirs         => [ '/path/to/dictionaries' ],
        default_locale => [ 'ru_RU' ], # By default en_US
    } );

    # using default locale
    print $bf->t( 'dictionary.akey' );
    print $bf->t( 'dictionary.firstkey.nextkey', { foo => 'bar' } );

    # using specified locale
    print $bf->t( 'dictionary.firstkey.nextkey', { foo => 'bar' }, 'by_BY' );

    # using scalar as count or value variable
    print $bf->t( 'dictionary.firstkey.nextkey', 90 );
    # same as
    print $bf->t( 'dictionary.firstkey.nextkey', { count => 90, value => 90 } );

    # set locale
    $bf->locale( 'en_US' );
    print $bf->t( 'dictionary.firstkey.nextkey', { foo => 'bar' } );

    # Get current locale
    print $bf->locale;

# DICTIONARIES

## Phrases Syntax

\#{varname} Echoes value of variable
((Singular|Plural1|Plural2)):variable Plural form
((Singular|Plural1|Plural2)) Short plural form for "count" variable

Example:

    I have #{nails_count} ((nail|nails)):nails_count

or short form

    I have #{count} ((nail|nails))

or with zero and onу plural forms:

    I have ((=0 no nails|=1 a nail|#{nails_count} nail|#{nails_count} nails)):nails_count

## Dictionary file example

Module support only YAML format. Create dictionary file like: **dictionary.en\_US.yaml** where
`dictionary` is name of dictionary and `en_US` - its locale.

    profile:
        apps:
            forums:
                new_topic: New topic
                last_post:
                    title : Last message
    demo:
        apples: I have #{count} ((apple|apples))
        list:
            - some content #{data}
            - some other content #{data}

# DETAILS

Словари грузятся при создании экземпляра, сразу в плоской форме
$self->{dictionaries}->{ru\_RU}->{dictname\_key}...

Причем все скалярные значения, при необходимости (есть спецсимволы Babelfish),
преобразуются в ссылки на скаляры (флаг - "нужно скомпилировать").

Метод t\_or\_undef получает значение по указанному ключу.

Если это ссылка на скаляр, то парсит и компилирует строку.

Если это ссылка на массив, то работаем со всеми элементами массива как со скалярами,
собираем полученные результаты компиляции в новый массив и возвращаем ссылку на этот массив.

Результат компиляции либо ссылка на подпрограмму, либо просто строка.

Если это ссылка на подпрограмму, мы просто вызываем ее с плоскими параметрами.

Если просто строка, то возвращаем её as is.

Поддерживается опция watch.

# METHODS

- locale

    Если указана локаль, устанавливет её. Если нет - возвращает.

- on\_watcher\_change

    Перечитывает все словари.

- look\_for\_watchers

    Обновляет словари оп мере необходимости, через ["on\_watcher\_change"](#on_watcher_change).

- t\_or\_undef

        $self->t_or_undef( 'main.key.subkey' , { paaram1 => 1 , param2 => 'test' } , 'ru' );

    Локализация по ключу.

    первой частью в ключе $key должен идти словарь, например, main.key
    параметр языка не обязательный.

    $params - хэш параметров

- t

        $self->t( 'main.key.subkey' , { paaram1 => 1 , param2 => 'test' } , 'ru' );

    Локализация по ключу.

    первой частью в ключе $key должен идти словарь, например, main.key
    параметр языка не обязательный.

    $params - хэш параметров

- has\_any\_value

        $self->has_any_value( 'main.key.subkey' );

    Проверяет есть ли ключ в словаре

    первой частью в ключе должен идти словарь, например, main.

- load\_dictionaries

    Загружает все yaml словари с диска

- load\_dictionary

    Загружает один yaml словарь с диска

- phrase\_need\_compilation

        $self->phrase_need_compilation( $phrase, $key )
        $class->phrase_need_compilation( $phrase, $key )

    Определяет, требуется ли компиляция фразы.

    Используется также при компиляции плюралов (вложенные выражения).

- prepare\_to\_compile

        $self->prepare_to_compile()

    Либо маркирует как refscalar строки в словарях, требующие компиляции,
    либо просто компилирует их.

- detect\_locale

        $self->detect_locale( $locale );

    Определяем какой язык будет использован.
    приоритет $locale, далее default\_locale.

- set\_fallback

        $self->set_fallback( 'by_BY', 'ru_RU', 'en_US');
        $self->set_fallback( 'by_BY', [ 'ru_RU', 'en_US' ] );

    Для указанной локали устанавливает список локалей, на которые будет производится откат
    в случае отсутствия фразы в указанной.

    Например, в вышеуказанных примерах при отсутствии фразы в
    белорусской локали будет затем искаться фраза в русской локали,
    затем в англоамериканской.

- \_flat\_hash\_keys

        _flat_hash_keys( $hash, '', $result );

    Внутренняя, рекурсивная.
    Преобразует хэш любой вложенности в строку, где ключи хешей разделены точками.

- \_process\_list\_items

        _process_list_items( $dictionary_values);

    Обрабатывает ключи словарей содержащие списки, и оборачивает в функцию для компиляции списка.
    Поддерживаются вложенные структуры в виде hashref и arrayref

# AUTHORS

- Akzhan Abdulin <akzhan@cpan.org>
- Igor Mironov <grif@cpan.org>
- Victor Efimov <efimov@reg.ru>
- REG.RU LLC
- Kirill Sysoev <k.sysoev@me.com>
- Alexandr Tkach <tkach@reg.ru>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by REG.RU LLC.

This is free software, licensed under:

    The MIT (X11) License
