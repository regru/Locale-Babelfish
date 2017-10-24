#!/usr/bin/env perl


=head1 stable test

=cut

use SRS::Perl;
use utf8;

use Test::Spec;
use Test::More::UTF8;

describe "SRS::L10N::Number" => sub {
    my $l10n = undef;

    before all => sub {
        require_ok "SRS::L10N::Lib2";
        $l10n = new_ok "SRS::L10N::Lib2";
    };

    it "should format decimal in spanish" => sub {
        like $l10n->decimal(1234.5, 'es'), qr|^1234,5$|;
    };

    it "should format percent in turkish" => sub {
        like $l10n->percent(0.05, 'tr'), qr|^%5$|;
    };

    it "should format USD in Canadian French" => sub {
        like $l10n->currency(9.99, 'USD', 2, 'fr-CA'), qr|^9,99\s\$\sUS|;
    };
};


runtests  unless caller;
