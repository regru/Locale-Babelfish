use strict;
use Test::Deep;
use Test::More tests => 18;

use FindBin qw($Bin);

use utf8;

use_ok( 'Locale::Babelfish' ) or exit 1;

my $dir = "$Bin";

my $cfg = {
        dirs         => [ $dir ],
        dictionaries => ['test'],
        default_lang => 'en_US',
        langs        => [ 'ru_RU', 'en_US' ],
};

my $l10n = Locale::Babelfish->new( $cfg, undef );

my $t = $l10n->t('test1.developers.some.test', {} );

is( $t, '[Babelfish:test1.developers.some.test]', 'No dictionary' );


cmp_ok( $l10n->t('test.simple', { dummy => ' test script ' } ) ,
        'eq', 'I am ' , 'dummy_parameter'
 );

cmp_ok( $l10n->t('test.dummy_key', { who => ' test script ' } ) ,
        'eq', '[Babelfish:test.dummy_key]' , 'dummy_key'
 );

cmp_ok( $l10n->t('test.simple', { who => 'test script' } ) ,
        'eq', 'I am test script' , 'simple_var'
 );

cmp_ok( $l10n->maketext('test' , 'case1.combine' , 10 , "example", 1) ,
        'eq' , 'I have 10 nails for example for 1 test', 'check1' );

cmp_ok( $l10n->t('test.case1.combine', { single => { test => { deep => 'example'} } , count => 10 , test => 2 } ) ,
        'eq' , 'I have 10 nails for example for 2 tests', 'check2' );

cmp_ok( $l10n->t('test.plural.case1', { test => 10 } ) ,
        'eq', 'I have 10 nails' , 'plural1'
 );

cmp_ok( $l10n->t('test.plural.case1', { test => 1 } ) ,
        'eq', 'I have 1 nail' , 'plural2'
 );

cmp_ok( $l10n->t('test.plural.case2', { test => 1 } ) ,
        'eq', 'I have 1 nail simple using' , 'plural3'
 );

cmp_ok( $l10n->t('test.plural.case3', 17 ) ,
        'eq', 'I have 17 big nails' , 'plural4'
 );

cmp_ok( $l10n->has_any_value('test.plural.case1' ) ,
        '==', 1 , 'has_any_value'
 );

cmp_ok( $l10n->has_any_value('test.plural.case1123' ) ,
        '==', 0 , 'has_any_value'
 );

$l10n->set_locale('ru_RU');

cmp_ok( $l10n->current_locale , 'eq', 'ru_RU', 'Check current locale');

cmp_ok( $l10n->t('test.simple.plural.nails4', { test => 1, test2 => 20 } ) ,
        'eq', 'Берём 1 гвоздь для 20 досок и вбиваем 1 гвоздь в 20 досок' , 'repeat_twice'
 );

cmp_ok( $l10n->t('test.simple.plural.nails', { test => 10 } ) ,
        'eq', 'У меня 10 гвоздей' , 'RU plural1'
 );

cmp_ok( $l10n->t('test.simple.plural.nails', { test => 3 } ) ,
        'eq', 'У меня 3 гвоздя' , 'RU plural2'
 );

cmp_ok( $l10n->t('test.simple.plural.nails3', { test => 1 } ) ,
        'eq', '1 у меня гвоздь' , 'RU plural3'
 );

done_testing;

