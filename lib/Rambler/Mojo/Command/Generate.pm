package Rambler::Mojo::Command::Generate;

use Mojo::Base 'Mojolicious::Command::Generate';

has namespaces => sub { [ __PACKAGE__, qw/Mojolicious::Command::Generate Mojo::Command::Generate/ ] };
1;
