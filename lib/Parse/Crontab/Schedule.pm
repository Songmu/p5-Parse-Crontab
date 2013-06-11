package Parse::Crontab::Schedule;
use 5.008_001;
use strict;
use warnings;
use Carp;
use Try::Tiny;

use Parse::Crontab::Schedule::Entity;

use Mouse;

my @SCHEDULES = qw/minute hour day month day_of_week/;

has $_ => (
    is => 'rw',
) for @SCHEDULES;

has user => (
    is => 'ro',
    isa => 'Maybe[Str]',
);

has definition => (
    is  => 'ro',
    isa => 'Str',
);

no Mouse;

my %DEFINITIONS = (
    yearly   => '0 0 1 1 *',
    annually => '0 0 1 1 *',
    monthly  => '0 0 1 * *',
    weekly   => '0 0 * * 0',
    daily    => '0 0 * * *',
    hourly   => '0 * * * *',
    reboot   => '@reboot',
);

my %ENTITY_PARAMS = (
    minute  => {
        range => [0,59],
    },
    hour    => {
        range => [0,23],
    },
    day     => {
        range => [1,31],
    },
    month   => {
        range   => [1,12],
        aliases => [qw/jan feb mar apr may jun jul aug sep oct nov dec/],
    },
    day_of_week => {
        range   => [0,7],
        aliases => [qw/sun mon tue wed thu fri sat/],
    },
);

sub BUILD {
    my $self = shift;

    my %s;
    if (my $def = $self->definition) {
        my $definition = $DEFINITIONS{$def};
        croak sprintf('bad time specifier: [%s]', $def) unless $definition;

        if ($def ne 'reboot') {
            @s{@SCHEDULES} = split /\s+/, $definition;
        }
    }
    else {
        $s{$_} = $self->$_ for @SCHEDULES;
    }

    if (exists $s{minute}) {
        for my $schedule (@SCHEDULES) {
            my $entity;
            try {
                $entity = Parse::Crontab::Schedule::Entity->new(
                    entity => $s{$schedule},
                    %{$ENTITY_PARAMS{$schedule}},
                    field  => $schedule,
                );
            }
            catch {
                croak "bad $schedule: $_";
            };
            $self->$schedule($entity);
        }
    }
}

sub parse {
    my ($cls, $str) = @_;

    my @s = split /\s+/, $str;
    my %args;
    for my $schedule (@SCHEDULES) {
        my $arg = shift @s;
        $args{$schedule} = $arg;
    }

    $cls->new(%args);
}

sub _check_warnings {
    my $self = shift;

    my @warnings;
    if ($self->minute.'' eq '*') {
        push @warnings,
            q{Specifying '*' for minutes means EVERY MINUTES. You really want to do that and to remove this warning, specify '*/1' explicitly.}
    }
    if ($self->day_of_week.'' ne '*' && $self->day.'' ne '*') {
        push @warnings,
            q{Both specifying 'day_of_week' and 'day' field causes unexpected behavior. You should seperate job entries.}
    }
    @warnings;
}

sub match {
    my ($self, %args) = @_;

    for my $s (qw/minute hour month/) {
        return unless $self->$s->match($args{$s});
    }

    if ($self->day_of_week.'' ne '*') {
        croak q{args year is not specified. could detect day_of_week.} unless $args{year};

        require Time::Piece;
        my $str = sprintf '%04d-%02d-%02d', $args{year}, $args{month}, $args{day};
        my $day = Time::Piece->strptime($str, '%Y-%m-%d');

        return unless $self->day_of_week->match($day->day_of_week);
    }
    else {
        return unless $self->day->match($args{day});
    }

    1; # matched
}

__PACKAGE__->meta->make_immutable;
