#!/usr/bin/env perl

use uni::perl;
use lib::abs '../lib';
use Test::More tests => 2;
use Test::NoWarnings;

package Test::Project;
use Rambler::Mojo;

    routing {
        bridge {
            path '/admin';
        };
        bridge {
            path '/:member_id';
            call 'root#member_chain';
            bridge {
                path '/:thread_id';
                call 'root#thread_chain';
                route {
                    call 'root#thread';
                };
                waypoint {
                    path '/comments';
                    route {
                        path '/:comment_id';
                        call 'root#comment';
                    };
                }
            };
        };
        bridge {
            path '/test';
            route {
                path '/another';
                call 'root#index';
            }
        };
        waypoint {
            path '/way1';
            call 'root#way1';
        };
    };

sub startup {
    warn "starting up...";
}

package main;

ok 1;
