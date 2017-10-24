=head1 stable test

ok

=cut

use utf8;
use SRS::Perl;

use Test::Spec;
use Test::More::UTF8;
use File::Spec ();

use SRS::Config;
use SRS::L10N::Lib2 ();

describe localize_datetime => sub {
    my $l10n;
    my $time;
    my ( $mday, $min );

    before all => sub {
        my $cfg = cfg->get( 'locales' );

        $cfg->{dirs} = [ map {
            File::Spec->file_name_is_absolute( $_ ) ? $_ : File::Spec->rel2abs( $_, cfg->base_path );
        } @{ $cfg->{dirs} } ];

        $l10n = SRS::L10N::Lib2->new( $cfg );
        $time = time();
        ( $mday, $min ) = (localtime( $time ))[3, 1];
    };

    for my $locale ( qw( en_US ru_RU ) ) {
        describe "in $locale locale" => sub {
            before all => sub {
                $l10n->locale( $locale );
            };

            for my $format ( qw(
                date.short
                date.default
                date.long
                time.short
                time.default
                time.long
            ) ) {
                it "localize ok in $format format" => sub {
                    ok $l10n->localize_datetime( $time, $format );
                };

                if ( $format =~ m/^date\./ ) {
                    it "with $format format respond with day of month" => sub {
                        like $l10n->localize_datetime( $time, $format ), qr/\b0?\Q$mday\E\b/;
                    };
                };

                if ( $format =~ m/^time\./ ) {
                    it "with $format format respond with minute" => sub {
                        my $two_digit_min = length($min) == 1 ? "0$min" : $min;
                        like $l10n->localize_datetime( $time, $format ), qr/\b\Q$two_digit_min\E\b/;
                    };
                };
            }
        };
    }
};


runtests  unless caller;
