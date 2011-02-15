#!/usr/bin/env perl

use uni::perl;
use lib::abs '../lib';
use Test::More tests => 3;
use Test::NoWarnings;
use Time::HiRes 'time';

BEGIN {
	use Mojolicious (); # Don't count Mojolicious time
	#use MojoX::Renderer::Xslate;
	my $start = time;
	use_ok( 'Rambler::Mojo' ) or print "Bail out!\n";
	my $delta = time - $start;
	diag "load = $delta";
	{
		local $TODO = "Fast load";
		cmp_ok $delta,'<',0.2, 'loaded < 0.2s';
	}
}

diag( "Testing Rambler::Mojo $Rambler::Mojo::VERSION, Perl $], $^X" );
