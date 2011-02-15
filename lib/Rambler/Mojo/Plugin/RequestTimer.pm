package Rambler::Mojo::Plugin::RequestTimer;

use uni::perl;
use parent 'Mojolicious::Plugin';
use Time::HiRes ();

sub register {
    my ($self, $app) = @_;
    warn "call register $self,$app from @{[ (caller)[1,2] ]}\n";

    # Start timer
    $app->plugins->add_hook(
        before_dispatch => sub {
            my ($self, $c) = @_;
            $c->stash('mojo.started' => [Time::HiRes::gettimeofday()]);
        }
    );

    # End timer
    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;
            warn "after dispatch...";
            return unless my $started = $c->stash('mojo.started');
            my $elapsed = sprintf '%f',
              Time::HiRes::tv_interval($started,
                [Time::HiRes::gettimeofday()]);
            my $rps     = $elapsed == 0 ? '??' : sprintf '%.3f', 1 / $elapsed;
            my $res     = $c->res;
            my $code    = $res->code || 200;
            my $message = $res->message || $res->default_message($code);

            my $req    = $c->req;
            my $method = $req->method;
            my $path   = $req->url->path || '/';

            $c->app->log->debug("$method $path $code $message (${elapsed}s, $rps/s).");
        }
    );
}

1;
