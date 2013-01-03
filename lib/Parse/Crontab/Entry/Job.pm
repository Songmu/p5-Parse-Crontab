package Parse::Crontab::Entry::Job;
use strict;
use warnings;

use Mouse;
extends 'Parse::Crontab::Entry';

has $_ => (
    is => 'rw',
) for qw/minute hour day month day_of_week/;

has command => (
    is  => 'rw',
    isa => 'Str',
);

has predefined_definition => (
    is  => 'rw',
    isa => 'Str',
    default => '',
);

no Mouse;

my %PRE_DEFINED = (
    yearly   => '0 0 1 1 * ',
    annually => '0 0 1 1 * ',
    monthly  => '0 0 1 * * ',
    weekly   => '0 0 * * 0 ',
    dayly    => '0 0 * * * ',
    hourly   => '0 * * * * ',
    reboot   => '@reboot ',
);

sub BUILD {
    my $self = shift;

    my $line = $self->line;

    if ($line =~ s/^@([^\s]+)//) {
        my $pre_define = $1;
        my $define = $PRE_DEFINED{$pre_define};

        unless ($define) {
            $self->set_error("Unknown schedule definition: \@$pre_define");
            return;
        }
        $self->predefined_definition($pre_define);
        $line = $define . $line;
    }

    unless ($line =~ /^\@reboot/) {
        my ($min, $hour, $day, $month, $dow, $command) = split /\s+/, $line, 6;
        unless ($command) {
            $self->set_error(sprintf '[%s] is not valid cron job', $self->line);
            return;
        }

        $self->minute($min);
        $self->hour($hour);
        $self->day($day);
        $self->month($month);
        $self->day_of_week($dow);
        $self->command($command);
    }
    else {
        my $command = +(split /\s+/, $line, 2)[1];
        unless ($command) {
            $self->set_error(sprintf '[%s] is not valid cron job', $self->line);
            return;
        }
        $self->command($command);
    }
}

__PACKAGE__->meta->make_immutable;
