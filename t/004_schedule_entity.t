use strict;
use warnings;
use utf8;
use Test::More;

BEGIN {
    use_ok 'Parse::Crontab::Schedule::Entity';
}

my $entity = new_ok 'Parse::Crontab::Schedule::Entity', [entity => '*', range => [0,7]];
is $entity->range_min, 0;
is $entity->range_max, 7;
is_deeply $entity->expanded, [0..7];

$entity = new_ok 'Parse::Crontab::Schedule::Entity', [entity => '*/2', range => [0,7]];
is_deeply $entity->expanded, [0,2,4,6];

$entity = new_ok 'Parse::Crontab::Schedule::Entity', [entity => '3,*/2', range => [0,7]];
is_deeply $entity->expanded, [0,2,3,4,6];

$entity = new_ok 'Parse::Crontab::Schedule::Entity', [entity => '2,3-5/2,2', range => [0,7]];
is_deeply $entity->expanded, [2,3,5];

done_testing;
