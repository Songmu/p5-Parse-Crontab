use strict;
use Test::More;

BEGIN {
    use_ok 'Parse::Crontab';
}

my $crontab = new_ok 'Parse::Crontab', [
    content => <<'...',
# comment
HOGE=FUGA
* * * * * perl
@daily perl
...
];

is scalar @{$crontab->entries}, 4;
isa_ok $crontab->entries->[0], 'Parse::Crontab::Entry::Comment';
isa_ok $crontab->entries->[1], 'Parse::Crontab::Entry::Env';
isa_ok $crontab->entries->[2], 'Parse::Crontab::Entry::Job';
isa_ok $crontab->entries->[3], 'Parse::Crontab::Entry::Job';

done_testing;
