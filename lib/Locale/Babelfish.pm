package Locale::Babelfish;

$Locale::Babelfish::VERSION = '0.01';


=head1 NAME

Locale::Babelfish - wrapper between Locale::Maketext and https://github.com/nodeca/babelfish format


=head1 VERSION

This document describes version 0.01 of Locale::Babelfish


=head1 SYNOPSIS

    package Foo;
    use Locale::Babelfish;

    my $bf = Locale::Babelfish->new( { dirs => [ '/path/to/dictionaries'] } );
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );


More sophisticated example:

    package Foo::Bar;

    use Locale::Babelfish;
    ...
    my $bf = Locale::Babelfish->new( {
            dirs         => [ '/path/to/dictionaries'],
            default_lang => ['ru_RU'],
            langs        => [{ 'uk_UA' => 'Foo::Bar::Lang::uk_UA' } , 'de_DE' ] # for custom languages specify they are plural forms
        },
        $logger # Logger for example Log::Log4Perl, not required parameter
        );
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );
    $bf->set_context_lang('en_US');
    warn $bf->t('dictionary.firstkey.nextkey', { foo => 'bar'} );

=head1 DESCRIPTION

Internationalisation with easy syntax.
Simple wrapper between Locale::Maketext and https://github.com/nodeca/babelfish format.
Created for using same dictionaries on backend and frontend.

=head1 Phrases Syntax

#{varname} Echoes value of variable
((Singular|Plural1|Plural2)):count Plural form

Example:

I have #{count} ((nail|nails)):count

or short form

I have #{count} ((nail|nails))

=head1 dictionary file example
Module support only yaml format.
create dictionary file like: dictionary.en_US.yaml where dictionary - is name of dictionary and en_US - his locale

profile: Profiel
  apps:
    forums:
      new_topic: New topic
      last_post:
            title : Last message
demo:
    apples: I have #{count} ((apple|apples))

=head1 Custom plural forms

By default locale will be inherited from en_US.
If you would like specify own, create module like this:
and implement quant_word function.

.....
package Locale::Babelfish::Lang::uk_UA;

use parent 'Locale::Babelfish::Maketext';
use strict;

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

1;
......

=head2 Dictionary encoding

    Use any convinient encoding.

=cut


use utf8;
use Modern::Perl;

use parent 'Class::Accessor::Grouped';

use Locale::Babelfish::Maketext;
use YAML::Tiny;
use Carp qw/ confess /;

our $EMPTY_VALUE = '_EMPTY_';

my ( $default_lang, $log, $lex, $dirs, $langs, $dictionaries, $default_dict, $suffix, %lhs, $lexicon_vars );
my $avaible_langs = [qw /en_US ru_RU/ ];

__PACKAGE__->mk_group_accessors( simple => qw/ context_lang / );

sub new {
    my ($class, $cfg, $logger) = @_;

    $log          = $logger;
    $default_lang = $cfg->{default_lang} || 'en_US';
    my $c_dicts   = $cfg->{dictionaries};
    my $c_langs   = $cfg->{langs};
    my $c_dirs    = $cfg->{dirs};

    $dictionaries = { map {$_ => 1} @{$c_dicts} };
    $default_dict = $c_dicts->[0];
    push @$c_langs ,@$avaible_langs;
    for my $lang ( @{$c_langs} ) {
        if ( ref $lang eq 'HASH'){
            my @keys = keys %{$lang};
            $langs->{$keys[0]} = $lang->{$keys[0]};
        }
        else {
            $langs->{$lang} = 'ok';
        }
    }

    $dirs         = [ map {$_ . ''} @{$c_dirs} ];
    $suffix       = $cfg->{suffix} || 'yaml';

    my $self = bless {
        context_lang => $default_lang,
    }, $class;

    $self->check_dictionaries;

    return $self;
}

=head2 set_context_lang

    $self->set_context_lang( 'ru_RU' );

    Setting current context.

=cut

sub set_context_lang {
    my ($self, $lang) = @_;
    $self->{context_lang} = ($lang and exists $langs->{$lang}) ? $lang : $default_lang;
}

=head2 check_dictionaries

    $self->check_dictionaries();

    check what changed at dictionaries

=cut

sub check_dictionaries {
    my $self = shift;

    state $dict_files = [];

    my $files = $self->_get_files;
    while (my ($dictname, $data) = each %$files) {
        #next unless exists $dictionaries->{$dictname};
        $dictionaries->{$dictname} = 1;
        push @$dict_files, values %{$data->{langs}};
    }

    map {
        $self->_load_file($_->{dict}, $_->{lang}, $_->{file});
    } @$dict_files;

}

=head2 t

    Get internationalized value for key from dictionary.

    $self->t( 'main.key.subkey' , { paaram1 => 1 , param2 => { next_level  => 'test' } } );
    Where main - is dictionary, key.subkey - key at dictionary

=cut

sub t {
    my ($self, $dictname_key , $params ) = ( shift, shift, shift );

    my ( $dictname, $key ) = $self->_parse_dictname_key( $dictname_key );
    Carp::confess "wrong dictionary $dictname"  unless exists $dictionaries->{$dictname};
    Carp::confess "key missed"        unless $key;

    my $lang = $self->{context_lang};
    $lang = exists $langs->{$lang} ? $lang : $default_lang;

    my $flat_params = $self->_flat_hash_keys($params);

    my @params;

    for my $k ( keys %$flat_params ) {
        next unless exists $lexicon_vars->{$dictname}->{$lang}->{$key}->{$k};
        my $positon_in_array =  $lexicon_vars->{$dictname}->{$lang}->{$key}->{$k} - 1;
        $params[$positon_in_array] = $flat_params->{$k} if $positon_in_array >= 0;
    }

    return $self->_localize_maketext($dictname, undef, $key, @params);
}

=head2 has_any_value

    $self->has_any_value( 'main.key.subkey' );

    Check exist or not key in dictionary.
    Where main - is dictionary, key.subkey - key at dictionary

=cut

sub has_any_value {

    my ( $self, $dictname_key ) = ( shift, shift );

    my ( $dictname, $key ) = $self->_parse_dictname_key( $dictname_key );
    Carp::confess "wrong dictionary"  unless exists $dictionaries->{$dictname};
    Carp::confess "key missed"        unless $key;


    $dictname ||= $default_dict;
    my $lang = $self->{context_lang};
    $lang = exists $langs->{$lang} ? $lang : $default_lang;

    my $val;
    if (my $lh = $lhs{$dictname}{$lang}) {
        $val = $lh->lexicon->{$key};
        $val = undef if $val and $val eq $EMPTY_VALUE;
    }

    if (!$val and $default_lang ne $lang and my $dlh = $lhs{$dictname}{$default_lang}) {
        $val = $dlh->lexicon->{$key};
        $val = undef if $val and $val eq $EMPTY_VALUE;
    }

    return $val ? 1 : 0;
}


=head2 maketext

    $self->maketext( 'dict', 'key' , $param1, ... $paramN );

=cut

sub maketext  {shift->_localize_maketext(shift, undef, @_)}

sub _babelfish_converter {
    my ( $self , $data_yaml ) = @_;

    my $data;
    my $vars;

    foreach my $key (keys %$data_yaml) {
        my $content = $data_yaml->{$key};

        my ( @single_vars ) = $content =~ m{\#\{(.+?)\}}xmsig;

        push @single_vars, 'count';

        my ( @plural_vars ) = $content =~ m{\(\(.+?\)\)(?=\:(.+?)\b)?}xmsig;

        my $i = 1;

        my $numered_vars;
        for my $key ( @single_vars, @plural_vars )  {
            next if  !$key || exists $numered_vars->{$key} ;
            $numered_vars->{$key} = $i;
            $i++;
        }

        my ( @plurals ) = $content =~ m{(\(\(.+?\)\))(?=\:(.+?)\b)?}xmsig;

        for ( $i = 0; $i < @plurals; $i +=2 ) {
            my $construction = $plurals[$i];
            next unless $construction;
            my $var = $plurals[$i+1] || 'count';
            my ( $plural_list ) = $construction =~ m{\(\((.+?)\)\)}xmsig;
            my $orig_list =  $plural_list;

            $orig_list =~ s {\|}{\\\|}xmsig;

            $plural_list =~ s{\|}{\,}xmsig;

            my $locale_text_string = "[numb,_" . $numered_vars->{$var} . ",$plural_list]";
            $content =~ s{\(\($orig_list\)\)(?:\:$var\b)}{$locale_text_string}xmsig;

            my $short_form = "[numb,_" . $numered_vars->{count} . ",$plural_list]";
            $content =~ s{\(\($orig_list\)\)(?!\:)}{$short_form}xmsig;
        }

        foreach my $var ( keys %$numered_vars ) {
            my $numb = $numered_vars->{$var};
            $content =~ s{\#\{$var\}}{\[_$numb\]}xmsig;
        }

        $data->{$key} = $content;
        $vars->{$key} = $numered_vars;
    }
    return ( $data , $vars );

}

sub _localize_maketext  {
    my ($self, $dictname, $lang) = (shift, shift, shift);
    $dictname ||= $default_dict;
    $lang ||= $self->{context_lang};
    $lang = exists $langs->{$lang} ? $lang : $default_lang;

    my $val;
    eval {
        if (my $lh = $lhs{$dictname}{$lang}) {
            $val = $lh->maketext(@_);
            $val = undef if $val and $val eq $EMPTY_VALUE;
        }
        if (!$val and $default_lang ne $lang and my $dlh = $lhs{$dictname}{$default_lang}) {
            $val = $dlh->maketext(@_);
            $val = undef if $val and $val eq $EMPTY_VALUE;
        }
    };

    $log->debug("Babelfish: maketext error: $@") if ( $log && $@ );

    return $val || "[Babelfish:$_[0]]";
}

sub _flat_hash_keys {
    my $self  = shift;
    my $hash  = shift;
    my $ln    = shift || '';
    my $store = shift || {};
    return  if ref($hash) ne 'HASH';
    for my $key ( keys %{$hash} ) {
        if (ref($hash->{$key}) eq 'HASH') {
            my $bc = $ln;
            $ln  .=  ($ln) ? ".$key" : $key;
            $store = $self->_flat_hash_keys( $hash->{$key}, $ln, $store );
            $ln = $bc;
        } else {
            my $ln1  =  ($ln) ? "$ln.$key" : $ln.$key;
            $store->{$ln1} = $hash->{$key};
        }
    }
    return $store;
}


sub _get_files {
    my $self = shift;
    my %files;
    foreach my $dir (@$dirs) {
        my $ok = opendir(my $dh, $dir);
        unless ($ok) {
            $log->debug("Cannot open dir $dir: $!") if ( $log );
            next;
        }
        while (my $entry = readdir $dh) {
            next if $entry eq '.' or $entry eq '..';
            next unless rindex($entry, $suffix) == length($entry) - length($suffix);
            my $file = "$dir/$entry";
            my @tmp = split '\.', $entry;
            my $cur_suffix = pop @tmp;
            my $lang = pop @tmp;
            my $dictname = join('.', @tmp);
            next unless $cur_suffix eq $suffix;

            my $row = $files{$dictname} ||= {dict => $dictname, langs => {}};
            $row->{langs}{$lang} = {dict => $dictname, file => $file, lang => $lang};
        }
        closedir $dh;
    }
    return \%files;
}



sub _load_file {
    my ( $self, $dictname, $lang, $file, $forced_read ) = @_;
    $forced_read //= 0;
    $file //= _file($dictname, $lang);

    state $last_mtimes = {};
    my $last_mtime = $last_mtimes->{$file};

    return $lex->{$dictname}{$lang} if ($last_mtime and $last_mtime == (stat $file)[9]) && !$forced_read;
    $last_mtimes->{$file} = (stat $file)[9];


    my $content;

    eval {
        $content = YAML::Tiny->new->read( $file )
    };

    $log->debug("BabelFish: cannot parse file $file: $@") if ( $log && $@ );

    my $data_yaml = $self->_flat_hash_keys($content->[0]) || {} ;

    my ( $data , $vars ) = $self->_babelfish_converter($data_yaml);

    if (exists $dictionaries->{$dictname}) {
        my $lh = $lhs{$dictname}{$lang};
        unless ($lh) {
            my $parent = $langs->{$lang} eq 'ok' ? '' : $langs->{$lang};
            $lh = $lhs{$dictname}{$lang} = Locale::Babelfish::Maketext->create_lh( $dictname, $lang, $data, $parent );
        }
        else {
            $lh->set_lexicon($data);
        }
    }

    $lex   ||= {};


    $lexicon_vars->{$dictname}->{$lang} = $vars || {};
    return $lex->{$dictname}{$lang} = $data;

}

sub _file {
    foreach my $dir (@$dirs) {
        my $fname = "$dir/$_[0].$_[1].$suffix";
        return $fname if -e $fname;
    }
    return;
}

sub _parse_dictname_key {
    my ($self, $dictname_key) = @_;

    my ( $dictname, $key ) = $dictname_key =~ m{\A(.+?)\.(.+?)\z}xmsig;

    return ( $dictname, $key );
}


=head1 SEE ALSO

L<Locale::Maketext>, Lhttps://github.com/nodeca/babelfish

=head1 AUTHORS

Mironov Igor E<lt>mironov.igor@gmail.com<gt>
Crazy Panda LLC
REG.RU LLC

=head1 COPYRIGHT

This software is released under the MIT license cited below.  Additionally,
when this software is distributed with B<Perl Kit, Version 5>, you may also
redistribute it and/or modify it under the same terms as Perl itself.

=head2 The "MIT" License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

=cut

1;
