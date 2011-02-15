package Rambler::Mojo;

use 5.012;
use strict;
use warnings;

=head1 NAME

Rambler::Mojo - The great new Rambler::Mojo!

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Rambler::Mojo;

    my $foo = Rambler::Mojo->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

use Mojolicious 1.1;
use Mojo::Base 'Mojolicious';
use uni::perl;
use MojoX::Renderer::Xslate;
use MojoX::Routes::DSL;
use JSON::XS;
use Rambler::Config 2;

use Rambler::Mojo::Plugins;
use Rambler::Mojo::Plugin::RequestTimer;
use Rambler::Mojo::Log;
use MojoX::Routes::DebugPrint;

has plugins => sub { Rambler::Mojo::Plugins->new };
has log     => sub { Rambler::Mojo::Log->new };
has config  => sub {
	my $self = shift;
	my $confroot = $self->home->rel_dir('config');
	my ($class) = ( lc ref $self ) =~ /^([^:]+)/;
	warn "setup config for $class at $confroot";
	unless (-d $confroot) {
		$self->log->error("Config root `$confroot' not exists. Create it with scripts/$class baseconfig" );
		exit;
=for rem
		for (
			 $confroot,
			"$confroot/base",
			"$confroot/base",
		)
		mkdir $confroot         or die "Can't create config root: $confroot: $!";
		mkdir "$confroot/base"  or die "Can't create config root: $confroot: $!";
=cut
	}
	my $config = Rambler::Config->new(root => $confroot)->config($class);
};

=for TODO
	* Fast up request/response
=cut

sub import {
    no strict 'refs';
    my $class = shift;
    my $caller = caller();
    push @{ $caller.'::ISA'},$class;
    my @router_subs =  grep $_ ne 'routing', @MojoX::Routes::DSL::EXPORT;
    my $routing;
    *{ $caller.'::routing' } = sub (&) {
        $routing = shift;
        #warn "setup routing";
    };
    *{ $caller.'::startup_routing' } = sub {
        $routing or warn("No routing set up for $caller"),return;
        my $routes = &MojoX::Routes::DSL::routing( $routing,shift()->routes );
        MojoX::Routes::DebugPrint->new($routes)->print();
    };
    *{ $caller.'::'.$_ } = \&{'MojoX::Routes::DSL::'.$_} for @router_subs;

    @_ = ('uni::perl', ':dumper');goto &{ uni::perl->can('import') };
}

sub new {
    my $self = shift->Mojo::new(@_);

  # Transaction builder
  $self->on_build_tx(
    sub {
      my $self = shift;

      # Build
      my $tx = Mojo::Transaction::HTTP->new;

      # Hook
      $self->plugins->run_hook(after_build_tx => ($tx, $self));

      return $tx;
    }
  );

  # Routes
  my $r = $self->routes;

  # Namespace
    $r->namespace(ref($self).'::Controller');

  # Mode
  my $mode = $self->mode;

  # Renderer
    $self->plugin('xslate_renderer');
    my $renderer = $self->renderer;
    $renderer->default_handler('tx');
    my $json = JSON::XS->new->utf8->allow_blessed;
    $json->pretty if $mode eq 'development';
    $renderer->add_handler(
        json => sub {
            my ($r, $c, $output, $options) = @_;
            $$output = $json->encode($options->{json});
        }
    );

  # Static
  my $static = $self->static;

  # Home
  my $home = $self->home;

  # Root
  $renderer->root($home->rel_dir('templates'));
  $static->root($home->rel_dir('public'));

  # Hide own controller methods
  $r->hide(qw/AUTOLOAD DESTROY client cookie delayed finish finished/);
  $r->hide(qw/flash handler helper on_message param redirect_to render/);
  $r->hide(qw/render_data render_exception render_inner render_json/);
  $r->hide(qw/render_not_found render_partial render_static render_text/);
  $r->hide(qw/rendered send_message session signed_cookie url_for/);
  $r->hide(qw/write write_chunk/);

  # Log
  $self->log->path($home->rel_file("log/$mode.log"))
    if -w $home->rel_file('log');

  # Plugins
  $self->plugin('agent_condition');
  $self->plugin('default_helpers');
  $self->plugin('tag_helpers');
  $self->plugin('request_timer');
  $self->plugin('powered_by');

  # Reduced log output outside of development mode
  $self->log->level('error') unless $mode eq 'development';

  # Run mode
  $mode = $mode . '_mode';
  $self->$mode(@_) if $self->can($mode);

  # Startup
  $self->startup_routing;
  $self->startup(@_);

  return $self;
}

sub startup_routing {};

1;


=head1 AUTHOR

Mons Anderson, C<< <mons at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mons Anderson.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

=cut

1; # End of Rambler::Mojo
