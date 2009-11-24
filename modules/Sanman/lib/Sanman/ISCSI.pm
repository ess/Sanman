package Sanman::ISCSI;

use 5.006;
use strict;
use Sanman;
use Sanman::LVM;

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
  $self->{LVM} = Sanman::LVM->new();
  return $self;
}

sub make_target {
  my $self = shift;
  my( $targetname, $device ) = @_;

  my $lvinfo = $self->{LVM}->get_lv_info( $targetname );

  if( undef( $lvinfo->{'uuid'} ) ) {
    return undef;
  }
  
  my $vg = $lvinfo->{'vg'};
  my $targetconf = <<EOC;
Target iqn.2009-11.$targetname
  Lun 0 PATH=$device
  #MaxConnections   1
  InitialR2T   Yes
  ImmediateData    No
  MaxRecvDataSegmentLength 8192
  MaxXmitDataSegmentLength 8192
  MaxBurstLength   262144
  FirstBurstLength 65536
  DefaultTime2Wait 2
  DefaultTime2Retain 20
  MaxOutstandingR2T  8
  DataPDUInOrder   Yes
  DataSequenceInOrder  Yes
  ErrorRecoveryLevel 0
  HeaderDigest   CRC32C,None
  DataDigest   CRC32C,None

EOC

  open IETD, ">>/etc/ietd.conf";
  print IETD $targetconf;
  close IETD;
  $self->execute_system_command("/etc/init.d/iscsi-target restart");
}

1;
__END__

=head1 NAME

Sanman::ISCSI - Sanman ISCSI management module

=head1 SYNOPSIS

 # I bet you would like to see some example code.
 # So would I.

=head1 DESCRIPTION

This module provides iSCSI target management to the Sanman suite.

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
