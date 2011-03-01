use strict;
use warnings;
use Errno;
use BSD::Socket::Splice 'setsplice';

use Test::More tests => 51;

undef $@;
eval { setsplice() };
like($@, qr/^Usage: BSD::Socket::Splice::setsplice\(so, ...\) /,
    "setsplice function does not take 0 arguments");

undef $@;
eval { setsplice("foo") };
like($@, qr/^Bad filehandle: foo /, "setsplice function needs 1 filehandle");

undef $@;
eval { setsplice("foo", "bar") };
like($@, qr/^Bad filehandle: foo /, "setsplice function needs filehandles");

undef $@;
eval { setsplice(\*STDIN, "bar") };
like($@, qr/^Bad filehandle: bar /, "setsplice function needs 2 filehandles");

undef $@;
eval { setsplice(\*STDIN, \*STDOUT, "foobar") };
like($@, qr/^Non numeric max value for setsplice /,
    "setsplice function needs numeric 3rd argument");

undef $@;
eval { setsplice(\*STDIN, \*STDOUT, 0, "foobar") };
like($@, qr/^Too many arguments for setsplice /,
    "setsplice function does not take 4 arguments");

ok(!defined(setsplice(\*STDIN)), "setsplice function needs 1 socket");
ok($!{ENOTSOCK}, "setsplice function failed: $!");

ok(!defined(setsplice(\*STDIN, \*STDOUT)), "setsplice function needs sockets");
ok($!{ENOTSOCK}, "setsplice function failed: $!");

ok(!defined(setsplice(\*STDIN, \*STDOUT, 1)),
    "setsplice function with max needs sockets");
ok($!{ENOTSOCK}, "setsplice function with max failed: $!");

foreach my $max (qw(2**70 2**64 2**63)) {
    undef $!;
    setsplice(\*STDIN, \*STDOUT, eval $max);
    ok($!{EINVAL}, "setsplice max $max failed: $!");
}

foreach my $max (qw(2**32 4294967295 3000000000 2147483648 2147483647)) {
    undef $!;
    setsplice(\*STDIN, \*STDOUT, eval $max);
    ok($!{ENOTSOCK}, "setsplice max $max succeeded");
}

foreach my $max (qw(-2**32 -4294967295 -3000000000 -2147483648 -2147483647)) {
    undef $!;
    setsplice(\*STDIN, \*STDOUT, eval $max);
    ok($!{EINVAL}, "setsplice max $max invalid: $!");
}

foreach my $max (qw(2**62 2 1.8 1.5 1.3 1.0 1 0.8 0.5 0.3 0.0 0 -0.0 -0)) {
    undef $!;
    setsplice(\*STDIN, \*STDOUT, eval $max);
    ok($!{ENOTSOCK}, "setsplice max $max succeeded");
}

foreach my $max (qw(-0.3 -0.8 -1.0 -1 -1.3 -2**62 -2**63+1 -2**63 -2**64)) {
    undef $!;
    setsplice(\*STDIN, \*STDOUT, eval $max);
    ok($!{EINVAL}, "setsplice max $max invalid: $!");
}

use IO::Socket::INET;
my $sl = IO::Socket::INET->new(
    Proto => "tcp",
    Listen => 5,
    LocalAddr => "127.0.0.1",
) or die "socket listen failed: $!";

my $s = IO::Socket::INET->new(
    Proto => "tcp",
    PeerAddr => $sl->sockhost(),
    PeerPort => $sl->sockport(),
) or die "socket connect failed: $!";

my $ss = IO::Socket::INET->new(
    Proto => "tcp",
    PeerAddr => $sl->sockhost(),
    PeerPort => $sl->sockport(),
) or die "socket splice connect failed: $!";

ok(!defined(setsplice($s, \*STDIN)), "setsplice function needs 2 sockets");
ok($!{ENOTSOCK}, "setsplice function failed: $!");

ok(defined(setsplice($s, $ss)), "setsplice with 2 sockets failed: $!");
