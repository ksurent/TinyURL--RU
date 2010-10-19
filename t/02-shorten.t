use Test::More qw(no_plan);

use utf8;
use TinyURL::RU qw(shorten lengthen shorten_with_qrcode);

my @links = (
    [ 'http://whoyougle.ru/time/converter/gregorian/saka/24.8.1990', undef,    undef,    ],
    [ 'http://whoyougle.ru/texts/provider-choice/' ,                 'prefix', 'suffix', ],
    [ 'http://whoyougle.ru/money/currency/USD/RUB/100',              'prefix', undef,    ],
    [ 'http://whoyougle.ru/texts/site-tour/',                        undef,    'suffix', ],
);
my @links_autoincr = (
    'http://whoyougle.ru/texts/ten-best-undergrounds/',
    'http://whoyougle.ru/texts/car-rent-sites/',
    'http://whoyougle.ru/texts/online-education/',
);

is shorten('http://byst.ro'), undef, 'should not shorten itself';

for(@links) {
    my($url, $prefix, $suffix) = @$_;

    my $tiny = shorten($url, $prefix, $suffix);
    ok defined $tiny, 'shorten ok';

    my $re = qr{^http://byst\.ro/.+$};
    if(not defined $prefix and defined $suffix)    { $re = qr{^http://byst\.ro/$suffix$};          }
    elsif(defined $prefix and not defined $suffix) { $re = qr{^http://$prefix\.byst\.ro/?$};       }
    elsif(defined $prefix and defined $suffix)     { $re = qr{^http://$prefix\.byst\.ro/$suffix$}; }
    like $tiny || '', $re, 'looks like shorten url';

    my $long = lengthen($tiny);
    ok defined $long, 'lengthen ok';
    is $long, $url, 'lengthen url is equal to orginal';

    $tiny =~ s{http://}{};
    $long = lengthen($tiny);
    ok defined $long, 'lengthen ok (w/o scheme)';
    is $long, $url, 'lengthen url is equal to orginal (w/o scheme)';

    $tiny =~ s{byst\.ro}{tinyurl\.ru};
    $long = lengthen($tiny);
    ok defined $long, 'lengthen ok (w/ tinyurl host)';
    is $long, $url, 'lengthen url is equal to orginal (w/ tinyurl host)';

    my $qrcode = shorten_with_qrcode($url, $prefix, $suffix);
    ok defined $tiny, 'shorten_with_qrcode ok (scalar context)';
    ($qrcode, $tiny) = shorten_with_qrcode($url, $prefix, $suffix);
    ok defined $qrcode, 'shorten_with_qrcode ok (list context 1)';
    ok defined $tiny,   'shorten_with_qrcode ok (list context 2)';
}

my $start = 0;
for(@links_autoincr) {
    my $tiny = shorten($_, undef, 'autoincr', increment => 1);
    ok defined $tiny, 'shorten ok (w/ increment)';
    like $tiny || '', qr{autoincr\d*$}, 'looks like shorten url (w/ increment)';
    if($start) {
        my($current) = $tiny =~ /autoincr(\d+)/;
        ok $current > $start, 'increment is ok';
        $start = $current;
    }
    else {
        $start = '' unless defined $start;
        ($start) = $tiny =~ /autoincr(\d*)$/;
    }
}
