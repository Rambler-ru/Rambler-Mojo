package Rambler::Mojo::Plugins;

use Mojo::Base 'Mojolicious::Plugins';

has namespaces => sub { ['Rambler::Mojo::Plugin','Mojolicious::Plugin'] };

1;
