package Sanman::Server;

use 5.006;
use strict;
use Sanman::LVM;
use Sanman::ISCSI;
use Sanman::Block;

use base qw(JSON::RPC::Procedure);

use Data::Dumper;

our $VERSION = '0.0.0';
my $LVM = Sanman::LVM->new();
my $Block = Sanman::Block->new();
my $ISCSI = Sanman::ISCSI->new();

sub _allowable_procedure {
  return {
    list_pvs    => \&list_pvs,
    list_vgs    => \&list_vgs,
    list_lvs    => \&list_lvs,
    create_pv   => \&create_pv,
    create_vg   => \&create_vg,
    create_lv   => \&create_lv,
    pv_info     => \&pv_info,
    vg_info     => \&vg_info,
    lv_info     => \&lv_info,
  };
}

sub list_pvs : Public {
  my $s = shift;
  return $LVM->get_pvs();
}

sub list_vgs : Public {
  my $s = shift;
  return $LVM->get_vgs();
}

sub list_lvs : Public {
  my $s = shift;
  return $LVM->get_lvs();
}

sub list_available_blockdevs : Public {
  my $s = shift;
  return $Block->unused_block_devices();
}

sub pv_info : Public( pv:str ) {
  my $s = shift;
  my $obj = shift;
  my $pv = $obj->{pv};
  my $results = { 'stdout' => '', 'stderr' => '', 'code' => '' };

  if( $LVM->pv_exists( $pv ) ) {
    $results = $LVM->get_pv_info( $pv );
  } else {
    $results->{'stderr'} = "$pv does not exist as a physical volume.";
    $results->{'code'} = 9001;
  }

  print "pv_info results:\n\n" . Dumper( $results ) . "\n\n";
  return $results;
}

sub vg_info : Public( vg:str ) {
  my $s = shift;
  my $obj = shift;
  my $vg = $obj->{vg};
  my $results = { 'stdout' => '', 'stderr' => '', 'code' => '' };

  if( $LVM->vg_exists( $vg ) ) {
    $results = $LVM->get_vg_info( $vg );
  } else {
    $results->{'stderr'} = "The volume group '$vg' does not exist.";
    $results->{'code'} = 9101;
  }

  return $results;
}

sub lv_info : Public( vg:str, lv:str ) {
  my $s = shift;
  my $obj = shift;
  my $lv = $obj->{lv};
  my $vg = $obj->{vg};
  my $results =  { 'stdout' => '', 'stderr' => '', 'code' => '' };

  print "Sanman::Server::lv_info( { vg => $vg, lv => $lv } )\n";

  if( $LVM->lv_exists( $vg, $lv ) ) {
    print "$vg -> $lv exists!\n";
    $results = $LVM->get_lv_info( $vg, $lv );
    print "Just ran get_lv_info\n";
  } else {
    $results->{'stderr'} = "The volume '$vg -> $lv' does not exist.";
    $results->{'code'} = 9301;
  }

  return $results;
}

sub create_pv : Public( a:str ) {
  my $s = shift;
  my $obj = shift;
  my $pv = $obj->{a};
  my $results = { 'stdout' => '', 'stderr' => '', 'code' => '' };

  if( $LVM->pv_exists( $pv ) ) {
    $results->{'stderr'} = "$pv already exists as a physical volume.";
    $results->{'code'} = 9002;
  } elsif( $Block->is_available( $pv ) ) {
    $results = $LVM->make_pv( $pv );
  } else {
    $results->{'stderr'} = "$pv is not a viable block device.";
    $results->{'code'} = 9003;
  }

  return $results;
}

sub create_vg : Public( a:str, b:str ) {
  my $s = shift;
  my $obj = shift;
  my $results = { 'stdout' => '', 'stderr' => '', 'code' => '' };

  my ($vg, $pv) = ( $obj->{a}, $obj->{b} );

  if( $LVM->pv_exists( $pv ) ) {
    if( $LVM->pv_available( $pv ) ) {
      $results = $LVM->make_vg( $vg, $pv );
    } else {
      $results->{'code'} = 9102;
      $results->{'stderr'} = "$pv is already assigned to a volume group."
    }
  } else {
    $results->{'code'} = 9001;
    $results->{'stderr'} = "$pv does not exist as a physical volume."
  }

  return $results;
}

sub create_lv : Public( a:str, b:str, c:int ) {
  my $s = shift;
  my $obj = shift;
  my $results = {};

  my ($vg, $lv, $gigs) = ( $obj->{a}, $obj->{b}, $obj->{c} );

  $results = $LVM->make_lv( $lv, $gigs, $vg );

  return $results;
}

package Sanman::Server::system;

sub describe {
  {
    sdversion => '0.0.0',
    name => 'Sanman',
  }
}

1;
__END__

=head1 NAME

Sanman::Server - Sanman back-end server library

=head1 SYNOPSIS

 # I bet you would like to see some example code.
 # So would I.

=head1 DESCRIPTION

This module provides the back-end JSONRPC services that allow for
SAN management.

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
