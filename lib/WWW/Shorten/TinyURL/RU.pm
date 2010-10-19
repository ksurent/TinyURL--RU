package WWW::Shorten::TinyURL::RU;

use strict;
use warnings;
use base qw(WWW::Shorten::generic Exporter);

use Carp qw(croak);
use TinyURL::RU qw(shorten lengthen);

our $VERSION = '0.07';
our @EXPORT = qw(makeashorterlink makealongerlink);

sub makeashorterlink {
    my $url = shift || croak 'No URL passed to makeashorterlink';

    return shorten($url, @_);
}

sub makealongerlink {
    my $tinyurl_url = shift || croak 'No TinyURL.RU key / URL passed to makealongerlink';

    unless($tinyurl_url =~ m{^http://}) {
        $tinyurl_url = ($tinyurl_url =~ m{(?:tinyurl\.ru|byst\.ro)/})
            ? "http://$tinyurl_url"
            : "http://byst.ro/$tinyurl_url"
    }


    return lengthen($tinyurl_url);
}

__END__

=encoding utf8

=head1 NAME 

WWW::Shorten::TinyURL::RU - Compatibility layer between TinyURL::RU and WWW::Shorten

=head1 SYNOPSIS

See L<WWW::Shorten> and L<TinyURL::RU> docs.

=head1 SEE ALSO

L<WWW::Shorten>

L<TinyURL::RU>

=head1 AUTHOR

Алексей Суриков E<lt>ksuri@cpan.orgE<gt>

=head1 LICENSE

This program is free software, you can redistribute it under the same terms as Perl itself.
