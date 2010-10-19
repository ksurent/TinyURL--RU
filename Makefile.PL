use inc::Module::Install;

perl_version 5.006;
all_from      'lib/TinyURL/RU.pm';
requires      'URI::Escape';
requires      'XML::LibXML';
requires      'LWP::Simple';
requires      'Encode';
recommends    'WWW::Shorten';
test_requires 'Test::Exception';

WriteAll;
