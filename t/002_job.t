use strict;
use warnings;
use utf8;
use Test::More;
BEGIN {
    use_ok 'Parse::Crontab::Entry::Job';
}

my $entry = new_ok 'Parse::Crontab::Entry::Job', [line => '* * * * * perl', line_number => 1];
ok !$entry->is_error;
is $entry->minute, '*';
is $entry->hour, '*';
is $entry->day, '*';
is $entry->month, '*';
is $entry->day_of_week, '*';
is $entry->command, 'perl';

my $entry = new_ok 'Parse::Crontab::Entry::Job', [line => '@hourly perl', line_number => 1];
ok !$entry->is_error;
is $entry->minute, '0';
is $entry->hour, '*';
is $entry->day, '*';
is $entry->month, '*';
is $entry->day_of_week, '*';
is $entry->command, 'perl';

$entry = new_ok 'Parse::Crontab::Entry::Job', [line => '* * * *  perl', line_number => 1];
ok $entry->is_error;

done_testing;
