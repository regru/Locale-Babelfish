=head1 stable test

ok

=cut

use utf8;
use SRS::Perl;

use Test::Spec;
use Test::Exception;
use Test::More::UTF8;

use SRS::L10N::Phrase::Compiler ();

describe "SRS::L10N::Phrase::Compiler" => sub {
    my $compiler;

    before all => sub {
        $compiler = new_ok 'SRS::L10N::Phrase::Compiler';
    };

    it "should compile literal" => sub {
        my $res = $compiler->compile([
            SRS::L10N::Phrase::Literal->new( text => '"разное"' ),
        ]);

        is $res, '"разное"';
    };

    it "should compile variables" => sub {
        my $res = $compiler->compile([
            SRS::L10N::Phrase::Literal->new( text => 'итого ' ),
            SRS::L10N::Phrase::Variable->new( name => 'count' ),
            SRS::L10N::Phrase::Literal->new( text => ' рублей' ),
        ]);

        is $res->({ count => 5 }), 'итого 5 рублей';
    };

    it "should compile plurals" => sub {
        my $res = $compiler->compile([
            SRS::L10N::Phrase::Literal->new( text => 'итого ' ),
            SRS::L10N::Phrase::Variable->new( name => 'count' ),
            SRS::L10N::Phrase::PluralForms->new(
                locale => 'ru_RU',
                name => 'count',
                forms => {
                    strict => {},
                    regular => [
                        [
                            SRS::L10N::Phrase::Literal->new( text => ' рубль' ),
                        ],
                        [
                            SRS::L10N::Phrase::Literal->new( text => ' рубля' ),
                        ],
                        [
                            SRS::L10N::Phrase::Literal->new( text => ' рублей' ),
                        ],
                    ]
                }
            ),
        ]);

        is $res->({ count => 1 }), 'итого 1 рубль';
        is $res->({ count => 5 }), 'итого 5 рублей';
    };

};



runtests  unless caller;
