BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 10;
use strict;
use warnings;

use_ok( 'Thread::Synchronize' );
can_ok( 'Thread::Synchronize',qw(
 import
) );

my $script = 'test1';
ok( open( my $handle,'>',$script ),	'create test script' );

ok( (print $handle <<'EOD'),		'write test script' );
use threads;
use threads::shared;

use Thread::Synchronize;

sub a : synchronize {
    my $tid = threads->tid;
    foreach (1..3) {
        print "$tid: $_\n";
        sleep 1;
    }
} #a

$| = 1;
my @thread;
push( @thread,threads->new( \&a ) ) foreach 1..3;

$_->join foreach @thread;
EOD

ok( close( $handle ),			'close test script' );

ok( open( $handle,"$^X -Ilib $script|" ),'run test script and fetch output');

my %seen;
my $tests;
while (<$handle>) {
    last unless m#^(\d+):#; $tests++;
    my $seen = $1;
    last if $seen{$seen}; $tests++;
    $seen{$seen} = $seen;
    foreach my $times (1..2) {
        last unless <$handle> =~ m#^$seen:#; $tests++;
    }
}
is( "@{[sort keys %seen]}",'1 2 3','check if all threads returned' );
is( $tests,'12','check if all lines returned' );

ok( close( $handle ),			'check if closing is ok' );
ok( unlink( $script ),			'remove test files' );
