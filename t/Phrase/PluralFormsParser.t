=head1 stable test

ok

=cut

use utf8;
use SRS::Perl;

use Test::Spec;
use Test::More::UTF8;

use SRS::L10N::Phrase::PluralFormsParser ();
use SRS::L10N::Phrase::Literal ();

describe "SRS::L10N::Phrase::PluralFormsParser" => sub {
    my $parser;

    before all => sub {
        $parser = new_ok "SRS::L10N::Phrase::PluralFormsParser";
    };

    describe init => sub {
        before all => sub {
            $parser->init( 'abc' );
        };

        it "should have no regular forms" => sub {
            cmp_deeply $parser->regular_forms, [];
        };

        it "should have no strict forms" => sub {
            cmp_deeply $parser->strict_forms, {};
        };

        it "should have phrase" => sub {
            cmp_deeply $parser->phrase, "abc";
        };
    };

    describe parse => sub {
        it "should parse regular forms" => sub {
            cmp_deeply $parser->parse("a|b|c"), {
                strict => {},
                regular => [
                    [ SRS::L10N::Phrase::Literal->new( text => 'a' ) ],
                    [ SRS::L10N::Phrase::Literal->new( text => 'b' ) ],
                    [ SRS::L10N::Phrase::Literal->new( text => 'c' ) ],
                ],
            };
        };

        it "should parse strict forms" => sub {
            cmp_deeply $parser->parse("=1a|=0 b|=4 c"), {
                strict => {
                    1 => [ SRS::L10N::Phrase::Literal->new( text => 'a' ) ],
                    0 => [ SRS::L10N::Phrase::Literal->new( text => 'b' ) ],
                    4 => [ SRS::L10N::Phrase::Literal->new( text => 'c' ) ],
                },
                regular => [],
            };
        };

        it 'should allow escaped "|" character' => sub {
            cmp_deeply $parser->parse("a\\||b"), {
                strict => {},
                regular => [
                    [ SRS::L10N::Phrase::Literal->new( text => 'a|' ) ],
                    [ SRS::L10N::Phrase::Literal->new( text => 'b' ) ],
                ],
            };
        };

        it "should not overwrite results of previous parsing" => sub {
            my $prev_results = $parser->parse("a|b|c");
            $parser->parse("d|a|b");
            cmp_deeply $prev_results, {
                strict => {},
                regular => [
                    [ SRS::L10N::Phrase::Literal->new( text => 'a' ) ],
                    [ SRS::L10N::Phrase::Literal->new( text => 'b' ) ],
                    [ SRS::L10N::Phrase::Literal->new( text => 'c' ) ],
                ],
            };
        };
    };
};

runtests  unless caller;
