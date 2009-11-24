package Sanman::Block;

use 5.006;
use strict;
use Sanman;

require Exporter;

our @ISA = qw( Sanman );

our %EXPORT_TAGS = ( 'all' => [ qw( 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.0.0';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  return $self;
}

sub get_mounted_block_devices {
  my $self = shift;
  my @mounts;
  my @temp = `mount 2>/dev/null`;
  @temp = map { $self->strip($_) } @temp;

  foreach my $t (@temp) {
    if( $t =~ /^(\/dev\/[hs]d\w+)\s.*$/ ) {
      push(@mounts, $1);
    }
  }
  
  return \@mounts;
}

sub get_block_devices {
  my $self = shift;
  my @blocks;
  my @blines = `/sbin/sfdisk -d 2>/dev/null`;

  foreach my $line (@blines) {
    if( $line =~ /^(\/dev\/[hs]d\w+)\s+:\s+start=\s*[0-9]+,\s+size=\s*[0-9]+,\s+Id=\s*(\w+),*.*$/ ) {
      my ($dev, $type) = ($self->strip($1), $self->strip($2));
      unless( $type == '82' or $type == '5' or $type == '0' ) {
        push(@blocks, $dev);
      }
    }
  }

  @blocks = grep { /^\/dev\/[hs]d.*$/ } @blocks;

  return \@blocks;
}

sub unused_block_devices {
  my $self = shift;
  my $blocks = $self->get_block_devices();
  my $used = $self->get_mounted_block_devices();

  foreach my $u (@{$used}) {
    @{$blocks} = grep { !/^$u$/ } @{$blocks};
  }

  return $blocks;
}

sub is_available {
  my $self = shift;
  my $candidate = shift;

  my @available = @{ $self->unused_block_devices() };

  return scalar( grep { /^$candidate$/ } @available );
}

1;
__END__

=head1 NAME

Sanman::Block - Sanman block device library

=head1 SYNOPSIS

 # I bet you would like to see some example code.
 # So would I.

=head1 DESCRIPTION

This module provides block device interaction capabilities. 

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
