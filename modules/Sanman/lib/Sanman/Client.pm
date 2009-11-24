package Sanman::Client;

use 5.006;
use strict;
use Sys::Syslog;
use Sanman qw( strip );

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw( 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( 
);

our $VERSION = '0.0.0';


1;
__END__

=head1 NAME

Sanman::Client - Sanman client glue library

=head1 SYNOPSIS

 # I bet you would like to see some example code.
 # So would I.

=head1 DESCRIPTION

This module defines the client interface for programs to interact with
the Sanman back-end server.

=head2 Methods

=over 4

stub stub stub

=back

=head1 AUTHOR

Dennis Walters <pooster@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2009 Dennis Walters

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU               General Public License for more details.

You should have received a copy of the GNU General Public License               along with this program.  If not, see <http://www.gnu.org/licenses/>.
