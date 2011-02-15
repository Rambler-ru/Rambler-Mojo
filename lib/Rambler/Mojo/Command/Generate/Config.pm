package Rambler::Mojo::Command::Generate::Config;

use Mojo::Base 'Mojo::Command';
use Cwd;
use File::Spec;

has description => "Generate base config\n";
has usage       => "usage: $0 generate config [ name ]\n";


sub run {
	my $self = shift;
	my $class = $ENV{MOJO_APP} || 'MyApp';
	my $path  = $self->class_to_path($class);
	my $name  = $self->class_to_file($class);
	
	unless (-e "lib/$path") {
		my $cmd = Cwd::abs_path($0);
		my (undef,$dir,undef) = File::Spec->splitpath( $cmd,0 );
		my @dirs = File::Spec->splitdir( $dir );
		pop @dirs if !length $dirs[-1];
		if (@dirs > 1) {
			pop @dirs;
			$dir = File::Spec->catdir( @dirs );
			if (-e "$dir/lib/$path") {
				chdir $dir or die "Can't chdir to `$dir': $!";
			}
		}
		
	}
	-e "lib/$path" or die "Please, run generate config from root of the project\n";
	my $confroot = $self->rel_dir("config");
	
	unless (-d $confroot) {
		print "  * Generating config structure under $confroot\n";
		for (
			 $confroot,
			"$confroot/base",
			"$confroot/dev",
			"$confroot/dev/$ENV{USER}",
		) {
			$self->create_dir($_);
		};
		for (
			"$confroot/base/$name.yml",
			"$confroot/dev/$name.yml",
			"$confroot/dev/$ENV{USER}/$name.yml",
		) {
			$self->render_to_file('empty',$_);
		};
	} else {
		print "  * Already have config root `$confroot'\n" unless $self->quiet;
		unless (-d ($_ = "$confroot/dev/$ENV{USER}")) {
			$self->create_dir($_);
		}
		unless (-d ($_ = "$confroot/dev/$ENV{USER}/$name.yml")) {
			$self->render_to_file('empty',$_);
		} else {
			print "  * You already have your dev config `$_'\n" unless $self->quiet;
		}
	}
	
	return;
}

1;
__DATA__
@@ empty
---
