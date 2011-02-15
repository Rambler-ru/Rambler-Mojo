package Rambler::Mojo::Commands;

use Mojo::Base 'Mojolicious::Commands';

has namespaces => sub { [qw( Rambler::Mojo::Command Mojolicious::Command Mojo::Command )] };

1;
