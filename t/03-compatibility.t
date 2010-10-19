use Test::More;
use Test::Exception;

my $loaded = eval q{use WWW::Shorten; 1};
plan skip_all => 'WWW::Shorten is not installed' unless $loaded;

SKIP: {
    eval q{no WWW::Shorten; no WWW::Shorten::Metamark};

    no warnings 'once';

    plan tests => 8;

    $loaded = eval q{use WWW::Shorten 'TinyURL::RU'; 1};
    is $loaded, 1, 'plugin loaded ok';
    ok defined *main::makeashorterlink{CODE}, 'makeashorterlink exported ok';
    ok defined *main::makealongerlink{CODE},  'makealongerlink export ok';

    eval q{no WWW::Shorten; no WWW::Shorten::TinyURL::RU};

    $loaded = eval q{use WWW::Shorten 'TinyURL', ':short'; 1};
    is $loaded, 1, 'plugin with another names set loaded ok';
    ok defined *main::short_link{CODE}, 'short_link exported ok';
    ok defined *main::long_link{CODE},  'long_link exported ok';

    throws_ok { short_link() } qr{No URL passed to makeashorterlink},              'default behaviour for WWW::Shorten plugin';
    throws_ok { long_link()  } qr{No TinyURL key / URL passed to makealongerlink}, 'default behaviour for WWW::Shorten plugin'
}
