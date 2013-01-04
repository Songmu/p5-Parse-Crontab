use strict;
use warnings;
use utf8;
use Test::More;
BEGIN {
    use_ok 'Parse::Crontab::Schedule';
}

my $schedule = new_ok 'Parse::Crontab::Schedule', [
    minute      => '0',
    hour        => '1',
    day         => '1',
    month       => '1',
    day_of_week => '1',
];
is $schedule->minute->entity, '0';

$schedule = new_ok 'Parse::Crontab::Schedule', [
    definition => 'daily',
];
is $schedule->minute->entity, '0';

$schedule = new_ok 'Parse::Crontab::Schedule', [
    definition => 'reboot',
];
ok $schedule->definition;

done_testing;
