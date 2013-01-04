package Parse::Crontab::Schedule;
use 5.008_001;
use strict;
use warnings;
use Carp;
use Parse::Crontab::Schedule::Entity;

use Mouse;

my @SCHEDULES = qw/minute hour day month day_of_week/;

has $_ => (
    is => 'rw',
) for @SCHEDULES;

has definition => (
    is  => 'rw',
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
        croak sprintf('Unknown schedule definition: [%s]', $def) unless $definition;

        if ($def ne 'reboot') {
            @s{@SCHEDULES} = split /\s+/, $definition;
        }
    }
    else {
        $s{minute}      = $self->minute;
        $s{hour}        = $self->hour;
        $s{day}         = $self->day;
        $s{month}       = $self->month;
        $s{day_of_week} = $self->day_of_week;
    }

    if (exists $s{minute}) {
        for my $schedule (@SCHEDULES) {
            $self->$schedule(
                Parse::Crontab::Schedule::Entity->new(
                    entity => $s{$schedule},
                    %{$ENTITY_PARAMS{$schedule}},
                )
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;