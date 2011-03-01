package BSD::Socket::Splice;

use 5.012002;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(setsplice getsplice geterror SO_SPLICE);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('BSD::Socket::Splice', $VERSION);

1;

__END__

=pod

=head1 NAME

BSD::Socket::Splice - Perl interface to OpenBSD socket splicing

=head1 SYNOPSIS

  use BSD::Socket::Splice;

  $so = new IO::Socket;
  $sosp = new IO::Socket;
  setsplice($so, $sosp);
  setsplice($so, $sosp, $max);
  setsplice($so);

  $len = getsplice($so);
  $errno = geterror($so);

=head1 DESCRIPTION

The BSD::Socket::Splice module implements a Perl interface to OpenBSD
socket splicing.
Compared to the manual approach with pack() and setsockopt(), it
provides a convenient way to access the necessary system-calls.

Nothing is exported by default, the following functions can be
exported on demand:

=over 4

=item L<setsplice>($so, $sosp), L<setsplice>($so, $sosp, $max),
L<setsplice>($so)

Splice together the source socket $so and the drain socket $sosp.
Then the kernel will move network data from $so to $sosp without
further user-land interaction.
For bidirectional splicing two function-calls with exchanged socket
parameters are necessary.

The second form allows to specify a maximum number bytes to transfer.
Note that a short splice might happen which means that fewer data
has been moved.
If that has happened, a second call pointing to the same maximum
will succeed and move the outstanding data.

Splicing of two sockets will get dissolved automatically in case
of end-of-file at the source socket, if a read or write error occurred
or if the optional maximum has been reached.
An existing splicing can be dissolved manually by using the third
form.

=item L<getsplice>($so)

Return the number of bytes already transfered from this socket by
splicing.

=item L<geterror>($so)

Return the error number attached to this socket.
This is not specific to splicing but is added here for convenience.
All errors during data transfer can be retrieved from the source
socket.

=item L<SO_SPLICE>

Return the kernel constant for the socket splicing socket option.
It is not necessary to use this constant as the kernel interface
is encapsulated by this module.

=back

=head1 ERRORS

When called with bad argument types the functions carp.
In general L<setsplice>(), L<getsplice>(), L<geterror>() set $! and
return I<undef> in case of an error.
L<setsplice>() and L<getsplice>() try to convert between the I<off_t>
value of the operating system and Perl's integer and numeric value
automatically.
If they fail to do so, they set $! to EINVAL and return I<undef>.

=head1 SEE ALSO

setsockopt(2),
sosplice(9)

=head1 AUTHOR

Alexander Bluhm, E<lt>bluhm@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010,2011 by Alexander Bluhm

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
