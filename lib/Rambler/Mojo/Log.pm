package Rambler::Mojo::Log;

use Mojo::Base 'Mojo::Log';
use uni::perl;
use Fcntl ':flock';
use Carp 'croak';

use IO::File;

has handles => sub {
        my $self = shift;
        my @handles;
        if ( -t STDERR or !$self->path ) {
            #warn "stderr is a tty";
            binmode STDERR, ':utf8';
            push @handles, \*STDERR;
        }
        if ($self->path) {
            my $file = IO::File->new;
            my $path = $self->path;
            $file->open(">> $path") or croak qq/Can't open log file "$path": $!/;
            binmode $file, ':utf8';
            push @handles, $file;
        }

        return \@handles;
};

sub log {
    my ($self, $level, @msgs) = @_;

    # Check log level
    $level = lc $level;
    return $self unless $level && $self->is_level($level);

    my @time = localtime(time);
    my $time = sprintf '%04u-%02u-%02uT%02u:%02u:%02u', $time[5]+1900,$time[4]+1,@time[3,0,1,2];
    my $msgs = join "\n", @msgs;

    # Caller
    my $i;
    my ($pkg, $line) = (caller())[0, 2];
    ($pkg, $line) = (caller(++$i))[0, 2] while $pkg eq ref $self or $pkg eq 'Mojo::Log';

    # Lock
    for my $handle ( @{ $self->handles } ) {
        flock $handle, LOCK_EX;

        # Write
        if (-t $handle) {
            my $c = { error => 1, fatal => 1, warn => 3, info => 2, debug => 7  }->{$level};
            $handle->syswrite("$time $level $pkg:$line [$$]: \e[03${c};1m$msgs\e[0m\n");
        } else {
            $handle->syswrite("$time $level $pkg:$line [$$]: $msgs\n");
        }
    
        # Unlock
        flock $handle, LOCK_UN;
    }
    
    return $self;
}

1;
