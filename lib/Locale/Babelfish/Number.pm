package Locale::Babelfish::Number;

=encoding utf-8

=head1 NAME

SRS::L10N::Number

only

=cut

use utf8;
use SRS::Perl;

use CLDR::Number 0.09 ();

my %cldrs = ();

sub _cldr_of {
    my ( $locale ) = @_;
    return ( $cldrs{$locale} = CLDR::Number->new( locale => $locale ) );
}

sub decimal {
    my ( $self, $value, $locale, $precision ) = @_;
    return $value  unless length $value;
    $locale //= $self->locale;

    my $formatter = _cldr_of($locale)->decimal_formatter;

    if ( defined $precision ) {
        eval { $formatter->minimum_fraction_digits( $precision ); };
        eval { $formatter->maximum_fraction_digits( $precision ); };
    }

    $formatter->format( $value );
}

sub percent {
    my ( $self, $value, $locale ) = @_;
    return $value  unless length $value;
    $locale //= $self->locale;
    _cldr_of($locale)->percent_formatter->format( $value );
}

sub currency {
    my ( $self, $value, $currency_code, $precision, $locale ) = @_;
    return $value  unless length $value;

    $locale //= $self->locale;
    $currency_code //= $self->t('formatting.number.currency.default', undef, $locale);
    my $formatter = _cldr_of($locale)->currency_formatter( currency_code => $currency_code );
    $precision //= $self->t_or_undef("formatting.number.currency.$currency_code.precision");

    if ( defined $precision ) {
        eval { $formatter->minimum_fraction_digits( $precision ); };
        eval { $formatter->maximum_fraction_digits( $precision ); };
    }
    $formatter->format( $value );
}

sub cldr_of {
    my ( $self, $locale ) = @_;
    $locale //= $self->locale;
    return _cldr_of( $locale );
}


1;
