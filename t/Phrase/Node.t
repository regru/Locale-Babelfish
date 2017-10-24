=head1 stable test

ok

=cut

use utf8;
use SRS::Perl;

use Test::Spec;
use Test::More::UTF8;

use SRS::L10N::Phrase::Node ();


describe "SRS::L10N::Phrase::Node" => sub {
    my $node;

    before all => sub {
        $node = new_ok 'SRS::L10N::Phrase::Node', [ a => 1 ];
    };

    it "should save new args" => sub {
        is $node->{a}, 1;
    };

    describe to_perl_escaped_str => sub {
        it "should correcly escape string" => sub {
            my $str = "test \$test \@test \$test->{test} \\ \' \"";
            is eval($node->to_perl_escaped_str($str)), $str;
        };
    };

};

runtests  unless caller;
