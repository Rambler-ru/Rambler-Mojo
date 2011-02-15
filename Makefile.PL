use inc::Module::Install;

my $MI  = $Module::Install::MAIN;
name     'Rambler-Mojo';
all_from 'lib/Rambler/Mojo.pm';
author   q{Mons Anderson <mons@cpan.org>};
license  'perl';

build_requires 'Test::More';
build_requires 'lib::abs';

requires 'Mojolicious', '1.0';
requires 'uni::perl';
requires 'MojoX::Routes::DSL';
requires 'MojoX::Routes::DebugPrint';

auto_provides;
auto_install;

WriteAll;

print STDERR "Generated makefile for ".$MI->load('name')->name."-".$MI->load('version')->version."\n";
