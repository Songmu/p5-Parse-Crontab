use strict;
use warnings;
use utf8;
use Test::More;
use Parse::Crontab::Schedule;

my $schedule = Parse::Crontab::Schedule->parse('* * * * 5-7');
isa_ok $schedule, 'Parse::Crontab::Schedule';

done_testing;
