package Sanman::LVM;

use 5.006;
use strict;
use Sanman;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Sanman);

our %EXPORT_TAGS = ( 'all' => [ qw( 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.0.0';

my $SBIN = Sanman::sbin();
my $COMMONOPTS = Sanman::commonopts();

sub new {
  my $class = shift;
  my $self = $class->SUPER::new();
  return $self;
}

sub get_pvs {
  my $self = shift;
  my @lines = `$SBIN/pvs $COMMONOPTS -o pv_name`;
  @lines = map { $self->strip($_) } @lines;

  return \@lines;
}

sub pv_exists {
  my $self = shift;
  my $pv = shift;

  my @pvs = @{ $self->get_pvs() };
  return scalar( grep { /^$pv$/ } @pvs ) == 1;
}

sub pv_available {
  my $self = shift;
  my $pv = shift;

  return length( $self->get_pv_info()->{'vg'} ) == 0;
}

sub vg_exists {
  my $self = shift;
  my $vg = shift;

  my @vgs = @{ $self->get_vgs() };
  return scalar( grep { /^$vg$/ } @vgs ) == 0;
}

sub lv_exists {
  my $self = shift;
  my ($vg, $lv) = @_;

}

sub get_vgs {
  my $self = shift;
  my @lines = `$SBIN/vgs $COMMONOPTS -o vg_name`;
  @lines = map { $self->strip( $_ ) } @lines;

  return \@lines;
}

sub get_lvs {
  my $self = shift;
  my @lines = `$SBIN/lvs $COMMONOPTS -o vg_name,lv_name`;
  @lines = map { 
    my @temp = split(/\:/, $self->strip($_));
    my $vg = $temp[0];
    my $lv = $temp[1];
    #$self->get_lv_device_path($vg, $lv);
    "$vg -> $lv";
  } @lines;

  return \@lines;
}

sub get_pv_info {
  my $self = shift;
  my $pv = shift;
  my $infohash = {};
  my @lines = `$SBIN/pvs $COMMONOPTS -o pv_uuid,pv_name,pv_size,pv_free,pv_used,pv_pe_count,pv_pe_alloc_count,vg_name $pv`;
  @lines = map { $self->strip( $_ ) } @lines;

  foreach my $line (@lines) {
    if($line =~ /(.*):(.*):(.*):(.*):(.*):(.*):(.*):(.*)/) {
      $infohash = { 
        'uuid' => $1, 
        'name' => $2,
        'size' => $3, 
        'free' => $4, 
        'used' => $5, 
        'pe_count' => $6, 
        'pe_allocated' => $7, 
        'vg' => $8 
      };
    }
  }

  return $infohash;
}

sub get_vg_info {
  my $self = shift;
  my $vg = shift;
  my $infohash = {};
  my $line = $self->strip( `$SBIN/vgs $COMMONOPTS -o vg_uuid,vg_name,vg_size,vg_free,vg_extent_size,vg_extent_count,vg_free_count,lv_count $vg 2>/dev/null` );
    
  if($line =~ /(.*):(.*):(.*):(.*):(.*):(.*):(.*):(.*)/) {
    $infohash = { 
      'uuid' => $1, 
      'name' => $2,
      'size' => $3, 
      'free' => $4, 
      'extent_size' => $5, 
      'extent_count' => $6, 
      'extents_free' => $7, 
      'lv_count' => $8 
    };
  }
    
  return $infohash;
}

sub get_lv_device_path {
  my $self = shift;
  my ( $vg, $lv ) = @_;
  my $line = `$SBIN/lvdisplay -c $vg/$lv 2>/dev/null`;
  my @temp = split(/\:/, $self->strip( $line ) );
  return $temp[0];
}

sub get_lv_info {
  my $self = shift;
  my ($vg, $lv) = @_;
  my $infohash = {};

  $infohash->{ 'lv_path' } = &get_lv_device_path( $vg, $lv );

  if( length( $infohash->{ 'lv_path' } ) == 0 ) {
    return undef;
  }

  my $attributes;
  my $line = $self->strip( `$SBIN/lvs $COMMONOPTS -o lv_uuid,vg_name,lv_size,lv_attr $vg/$lv 2>/dev/null` ) ;
  if($line =~ /(.*):(.*):(.*):(.*)/) {
    $infohash = { 'uuid' => $1, 'vg' => $2, 'size' => $3 };
    $attributes = $4;
  }

  my @attrs = split( //, $attributes );

  $infohash->{ 'volume_type_attr'       } = $attrs[0];
  $infohash->{ 'permissions_attr'       } = $attrs[1];
  $infohash->{ 'allocation_policy_attr' } = $attrs[2];
  $infohash->{ 'fixed_attr'             } = $attrs[3];
  $infohash->{ 'state_attr'             } = $attrs[4];
  $infohash->{ 'device_attr'            } = $attrs[5];

  return $infohash;
}

sub make_pv {
  my $self = shift;
  my $pvpath = shift;

  my $results = {};
  $results = $self->execute_system_command("$SBIN/pvcreate $pvpath");

  return $results;
}

sub make_vg {
  my $self = shift;
  my $vgname = shift;
  my $pvpath = shift;
  my $results = {};

  print "Volume Group:  $vgname\n\nPhysical Volume:  $pvpath\n\n";
  $results = $self->execute_system_command("$SBIN/vgcreate $vgname $pvpath");

  return $results;
}

sub make_lv {
  my $self = shift;
  my $lvname = shift;
  my $lvsize = shift;
  my $vgname = shift;

  return $self->execute_system_command("$SBIN/lvcreate -L " . $lvsize . "G -n $lvname $vgname");
}

sub remove_pv {
  my $self = shift;
  my $pvpath = shift;

  return $self->execute_system_command("$SBIN/pvremove $pvpath");
}

sub remove_vg {
  my $self = shift;
  my $vgname = shift;

  return $self->execute_system_command("$SBIN/vgremove $vgname");
}

sub remove_lv {
  my $self = shift;
  my $lvname = shift;

  return $self->execute_system_command("$SBIN/lvremove $lvname");
}

1;
__END__

=head1 NAME

Sanman::LVM - Sanman LVM management module

=head1 SYNOPSIS

 use Sanman::LVM;
 # Create the 10GB logical volume 'brick' inside the 'storage' group
 make_lv( 'storage', 'brick', 10 );
 # Destroy the 'brick' volume
 remove_lv( 'storage', 'brick' );

=head1 DESCRIPTION

This module provides LVM management to the Sanman suite.

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
