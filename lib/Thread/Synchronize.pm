package Thread::Synchronize;

# Make sure we have version info for this module
# Make sure we do everything by the book from now on

$VERSION = '0.01';
use strict;

# Make sure we can do threads
# Make sure we can do shared variables

use threads ();
use threads::shared ();

# Make sure we can do a source filter

use Filter::Util::Call ();

# The hash containing the subroutine locks

our %VERSION; # this is called VERSION to save on a glob

# Satisfy -require-

1;

#---------------------------------------------------------------------------

# Methods needed by Perl

#---------------------------------------------------------------------------
#  IN: 1 class (ignored)

sub import {

# Obtain the current package (default package to be prefixed to subroutine name)

    my $package = caller();

# Obtain a reference to the fixit routine (ref only to so it'll clean up)
#  Obtain the parameters
#  Initialize the extra code to be generated

    my $fix = sub {
        my ($sub,$prototype,$attributes) = @_;
        my $code = '';

#  If the "synchronize" attribute is one of the specified attributes
#   Create the key to be used to synchronize this sub
#   Make sure that becomes a shared value
#   Create the extra code to lock the sub
#  Return the substitute string

        if ($attributes =~ s#\bsynchronize\b##) {
            my $key = $sub =~ m#::# ? $sub : $package.'::'.$sub;
            threads::shared::share( $VERSION{$key} );
            $code = 'lock( $'.__PACKAGE__."::VERSION{'$key'} );";
        }
        "sub $sub$prototype:$attributes\{$code";
    };

# Install the filter as an anonymous sub
#  Initialize status

    Filter::Util::Call::filter_add( sub {
        my $status;

# If there are still lines to read
#  Update package info if a package was found
#  Convert the line if "synchronize" attribute found
# Return the status

        if (($status = Filter::Util::Call::filter_read()) > 0) {
            $package = $1 if m#\bpackage\s+([^;]+);#;
#warn $_ if # uncomment if you want to see changed lines
            s#\bsub\s+((?:\w|_|::)+)([^:]*):([^{]+){#$fix->($1,$2,$3)#e;
        }
        $status;
    } );
} #import

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Synchronize - synchronize subroutine calls between threads

=head1 SYNOPSIS

    use Thread::Synchronize;  # activate :synchronize attribute

    sub foo : synchronize { } # only one subroutine running at a time

=head1 DESCRIPTION

                  *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0 and later.
 And then only when threads are enabled with -Dusethreads.  It
 is of no use with any version of Perl before 5.8.0 or without
 threads enabled.

                  *************************

This module currently adds one feature to threaded programs: the
":synchronize" subroutine attribute which causes calls to that subroutine
to be automatically synchronized between threads (only one thread can execute
that subroutine at a time).

=head1 CAVEATS

This module is implemented using a source filter.  This has the advantage
of not needing to incur any runtime overhead.  But this of course happens at
the expense of a slightly longer compile time.

=head1 TODO

Possibly also allow the ":method" attribute that would allow the same
subroutine only be called per instantiated object.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2003 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<threads>.

=cut
