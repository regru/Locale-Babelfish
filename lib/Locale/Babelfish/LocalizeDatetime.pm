package Locale::Babelfish::LocalizeDatetime;

=encoding utf-8

=head1 NAME

SRS::L10N::LocalizeDatetime

only

=cut

use utf8;
use SRS::Perl;

use POSIX qw( strftime );
use Time::Piece;
use Time::Local qw( timelocal );
use Reg::Utils::Math qw( round );

=head1 METHODS

=head2 localize_datetime

    $self->localize_datetime( $timestamp, 'date.short' );

Преобразует дату/время в формате Unix timestamp в локализованную строку с учетом дополнительных параметров.

Допустимые форматы перечислены в словаре formatting:

    date.short
    date.shorter
    date.default
    date.long
    time.short
    time.default
    time.long

Кроме того, поддерживаются форматы согласно L<POSIX::strftime>.

=cut

my %format_resolvers = (
    '%a' => sub {
        my ( $self, $format, $date ) = @_;
        return $self->t("formatting.date.abbr_day_names", { format => $format })->[$date->[6]]; # wday
    },
    '%A' => sub {
        my ( $self, $format, $date ) = @_;
        return $self->t("formatting.date.day_names", { format => $format })->[$date->[6]]; # wday
    },
    '%b' => sub {
        my ( $self, $format, $date ) = @_;
        return $self->t("formatting.date.abbr_month_names", { format => $format })->[$date->[4] + 1]; # mon
    },
    '%B' => sub {
        my ( $self, $format, $date ) = @_;
        return $self->t("formatting.date.month_names", { format => $format })->[$date->[4] + 1]; # mon
    },
    '%p' => sub {
        my ( $self, $format, $date ) = @_;
        my $hour = $date->[2];
        return uc $self->t( $hour < 12 ? "formatting.time.am" : "formatting.time.pm", { format => $format });
    },
    '%P' => sub {
        my ( $self, $format, $date ) = @_;
        my $hour = $date->[2];
        return lc $self->t( $hour < 12 ? "formatting.time.am" : "formatting.time.pm", { format => $format });
    },
);

sub localize_datetime {
    my ( $self, $date, $format, $options ) = @_;

    return  unless $date && $format;

    if ( ref($date) && $date->isa( 'Time::Piece' ) ) {
        $date = [ localtime( "$date" ) ]; # stringification to timestamp
    }
    elsif ( ref( $date ) ne 'ARRAY' ) {
        $date = [ localtime( $date ) ];
    }

    if ( $format =~ m/\A([^\.%]+)\.([^\.%]+)\z/ ) {
        $format = $self->t("formatting.$1.formats.$2", $options);
    }

    $format =~ s/(%[aAbBpP])/$format_resolvers{$1}->( $self, $format, $date )/ge;

    return strftime( $format, @{ $date } );
}

=head2 distance_of_time_in_words

    $self->distance_of_time_in_words( $from_time, $to_time, { include_seconds => 0|1 } );

Возвращает человеко-читаемое расстояние между датами.

=cut

sub distance_of_time_in_words {
    my ( $self, $from_time, $to_time, $options ) = @_;

    $from_time = timelocal( @{ $from_time } )  if ref( $from_time ) eq 'ARRAY';
    $from_time = "$from_time"  if ref( $from_time ) eq 'Time::Piece';
    $to_time = timelocal( @{ $to_time } )  if ref( $to_time ) eq 'ARRAY';
    $to_time = "$to_time"  if ref( $to_time ) eq 'Time::Piece';

    $options = {
        scope => 'formatting.datetime.distance_in_words',
        %{ $options // {} },
    };

    ( $from_time, $to_time ) = ( $to_time, $from_time )  if $from_time > $to_time;

    my $distance_in_minutes = round( ($to_time - $from_time)/60.0 );
    my $distance_in_seconds = round( $to_time - $from_time );

    if ( $distance_in_minutes < 2 ) {
        unless ( $options->{include_seconds} ) {
            if ( $distance_in_minutes == 0 ) {
                return $self->t( $options->{scope}. '.less_than_x_minutes', { count => 1 } );
            }
            else {
                return $self->t( $options->{scope}. '.x_minutes', { count => $distance_in_minutes } );
            }
        }
        if ( $distance_in_seconds < 5 ) {
            return $self->t( $options->{scope}. '.less_than_x_seconds', { count => 5 } );
        }
        elsif ( $distance_in_seconds < 10 ) {
            return $self->t( $options->{scope}. '.less_than_x_seconds', { count => 10 } );
        }
        elsif ( $distance_in_seconds < 20 ) {
            return $self->t( $options->{scope}. '.less_than_x_seconds', { count => 20 } );
        }
        elsif ( $distance_in_seconds < 40 ) {
            return $self->t( $options->{scope}. '.half_a_minute' );
        }
        elsif ( $distance_in_seconds < 60 ) {
            return $self->t( $options->{scope}. '.less_than_x_minutes', { count => 1 } );
        }
        else {
            return $self->t( $options->{scope}. '.x_minutes', { count => 1 } );
        }
    }
    elsif ( $distance_in_minutes < 45 ) {
        return $self->t( $options->{scope}. '.x_minutes', { count => $distance_in_minutes } );
    }
    elsif ( $distance_in_minutes < 90 ) {
        return $self->t( $options->{scope}. '.about_x_hours', { count => 1 } );
    }
    # 90 mins up to 24 hours
    elsif ( $distance_in_minutes < 1440 ) {
        return $self->t( $options->{scope}. '.about_x_hours', { count => round( $distance_in_minutes / 60.0 ) } );
    }
    # 24 hours up to 42 hours
    elsif ( $distance_in_minutes < 2520 ) {
        return $self->t( $options->{scope}. '.x_days', { count => 1 } );
    }
    # 42 hours up to 30 days
    elsif ( $distance_in_minutes < 43200 ) {
        return $self->t( $options->{scope}. '.x_days', { count => round( $distance_in_minutes / 1440.0 ) } );
    }
    # 30 days up to 60 days
    elsif ( $distance_in_minutes < 86400 ) {
        return $self->t( $options->{scope}. '.about_x_months', { count => round( $distance_in_minutes / 43200.0 ) } );
    }
    # 60 days up to 365 days
    elsif ( $distance_in_minutes < 525600 ) {
        return $self->t( $options->{scope}. '.x_months', { count => round( $distance_in_minutes / 43200.0 ) } );
    }
    else {
        my $from_obj = localtime( $from_time );
        my $to_obj = localtime( $to_time );
        my ( $fyear, $tyear ) = ( $from_obj->year, $to_obj->year );
        $fyear++  if $from_obj->mon >= 3;
        $tyear--  if $to_obj->mon < 3;
        my $leap_years = 0;
        for ( my $year = $fyear; $year <= $tyear; $year++ ) {
            $leap_years++  if Time::Piece->strptime( "$year-01-01", "%Y-%m-%d" )->is_leap_year;
        }
        my $minute_offset_for_leap_year = $leap_years * 1440;
        # Discount the leap year days when calculating year distance.
        # e.g. if there are 20 leap year days between 2 dates having the same day
        # and month then the based on 365 days calculation
        # the distance in years will come out to over 80 years when in written
        # English it would read better as about 80 years.
        my $minutes_with_offset = $distance_in_minutes - $minute_offset_for_leap_year;
        my $remainder           = $minutes_with_offset % 525600;
        my $distance_in_years   = int( $minutes_with_offset / 525600 );
        if ( $remainder < 131400 ) {
            return $self->t( $options->{scope}. '.about_x_years',  { count => $distance_in_years } );
        }
        elsif ( $remainder < 394200 ) {
            return $self->t( $options->{scope}. '.over_x_years',   { count => $distance_in_years } );
        }
        else {
            return $self->t( $options->{scope}. '.almost_x_years', { count => $distance_in_years + 1 } );
        }
    }
}

1;
