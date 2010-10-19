package TinyURL::RU;

use strict;
use warnings;
use base 'Exporter';

use URI::Escape;
use XML::LibXML;
use LWP::UserAgent;
use Encode qw(decode);

our @EXPORT_OK = qw(shorten lengthen shorten_with_qrcode);
our $VERSION   = '0.07';

use constant URL    => 'http://whoyougle.ru/net/api/tinyurl/?long=%s&prefix=%s&suffix=%s&option=%d&increment=%d';
use constant QRCODE => 'http://gd.whoyougle.ru/?type=QRcode&size=%i&value=%s';

our $QRCODE_SIZE = 100;

my $ua = LWP::UserAgent->new(
    timeout      => 3,
    parse_head   => 0,
    max_redirect => 0,
);

sub shorten {
    my $long   = shift || return;
    my $prefix = shift || '';
    my $suffix = shift || '';
    my %args   = @_;

    my $option = 1;
    if($prefix and not $suffix)    { $option = 2 }
    elsif(not $prefix and $suffix) { $option = 3 }
    elsif($prefix and $suffix)     { $option = 4 }

    $args{increment} = 0 unless defined $args{increment};
    return if $args{increment} and not $suffix;

    my $ua = LWP::UserAgent->new(
        agent   => __PACKAGE__ .  " $VERSION, ",
        timeout => 3,
    );
    my $resp = $ua->get(sprintf URL, uri_escape_utf8($long), $prefix, $suffix, $option, $args{increment});
    $resp->is_success or return;

    my $xml = eval { XML::LibXML->new->parse_string($resp->content) } or return;
    return if $xml->findvalue('/result/@error');

    my $short = $xml->findvalue('/result/tiny') || undef;

    $short;
}

sub lengthen {
    my $short = shift;

    unless($short =~ m{^http://}) {
        $short = ($short =~ m{(?:tinyurl\.ru|byst\.ro)/})
            ? "http://$short"
            : "http://byst.ro/$short"
    }

    my $resp = $ua->head($short);
    $resp->is_redirect or return;

    decode('utf-8', $resp->header('Location'));
}

sub shorten_with_qrcode {
    my $short = my $value = shorten(@_) || return;
    $value =~ s{^http://}{};
    my $qrcode = sprintf QRCODE, $QRCODE_SIZE, $value;

    if(wantarray) {
        return ($qrcode, $short);
    }
    else {
        return $qrcode;
    }
}

1;

__END__

=encoding utf8

=head1 NAME

TinyURL::RU - shorten URLs with byst.ro (aka tinyurl.ru)

=head1 SYNOPSIS

    use TinyURL::RU qw(shorten lengthen);
    my $long  = 'http://www.whitehouse.gov/';
    my $short = shorten($long);
    $long     = lengthen($short);

=head1 DESCRIPTION

This module provides you a very simple interface to URL shortening site http://byst.ro (aka http://tinyurl.ru).

IMPORTANT NOTE:

byst.ro/tinyurl.ru checks all incoming URLs for blacklisting.

=head1 FUNCTIONS

=head2 $short = shorten($long [, $prefix, $suffix, %options])

Takes long URL as first argument and returns its tiny version (or undef on error).

Optionaly you can pass $prefix and/or $suffix for tiny URL and some other options.

C<$prefix> will be used as subdomain in shortened URL.

C<$suffix> will be used as path in shortened URL.

Note: passing C<$prefix> and/or C<$suffix> may cause shortening fail if C<$prefix> or C<$suffix> is already taken by someone for different URL address.

There are some prefixes and suffixes which are reserved by byst.ro for its own purposes:

prefixes: www, bfm

suffixes: personal

C<%options> are:

=over 8

=item increment

Lets you to re-use same (almost) C<$suffix> for different URLs.

Implemented by automatical appending of an incremental number (starts with 1) on repeated requests with the same C<$suffix> and different URLs.

Note: this options works only with C<$suffix> passed.

=back

Simple example:

    $short = shorten($long1, 'hello');          # $short eq 'http://hello.byst.ro/'
    $short = shorten($long2, 'hello', 'world'); # $short eq 'http://hello.byst.ro/world'
    $short = shorten($long2, 'hello', 'world'); # $short eq 'http://hello.byst.ro/world' (again)

Incremental example:

    $short = shorten($long1, undef, 'hello');                # $short eq 'http://byst.ro/hello'
    $short = shorten($long2, undef, 'hello');                # short is undefined because 'hello' suffix already exists for $long1
    $short = shorten($long2, undef, 'hello', increment => 1) # $short eq 'http://byst.ro/hello1'
    $short = shorten($long3, undef, 'hello', increment => 1) # $short eq 'http://byst.ro/hello2'

=head2 $long = lengthen($short)

Takes shortened URL (or its path part) as argument and returns its original version (or undef on error).

Returned value is a valid UTF-8 string with URL within it.

=head2 $qrcode = shorten_with_qrcode($long [, $prefix, $suffix, %options])

=head2 ($qrcode, $short) = shorten_with_qrcode($long [, $prefix, $suffix, %options])

Does almost the same as shorten() and takes the same arguments.

In scalar context return value is a link to an image that has shortened URL encoded in it.
In list context returned is a list of the link to an image and shortened URL.

The image is a QR code which is readable by plenty of devices, e.g. mobile phones with camera.

Usage example:

    $w = $h = $TinyURL::RU::QRCODE_SIZE;
    $qrcode = shorten_with_qrcode($long4);

Later, in your templates:

    <img src="<% $qrcode %>" width="<% $w %>" height="<% $h %>"/>

=head1 VARIABLES

=head2 $QRCODE_SIZE

Sets the size of the QR code image. The image will be a square of $QRCODE_SIZE px.

The size must be between 100 and 1000 or it will be ignored.

Default value is 300.

=head1 AUTHOR

Алексей Суриков E<lt>ksuri@cpan.orgE<gt>

=head1 NOTE

There is a small convenience for you: a plugin for L<WWW::Shorten> comes with this distribution.

See L<WWW::Shorten::TinyURL::RU>.

=head1 SEE ALSO

L<WWW::Shorten::TinyURL::RU>

L<http://byst.ro/>

L<http://tinyurl.ru/>

L<http://en.wikipedia.org/wiki/QR_Code>

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
