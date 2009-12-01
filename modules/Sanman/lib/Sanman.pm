package Sanman;

use 5.006;
use strict;
use JSON;
use Sys::Syslog;
use IO::CaptureOutput qw(capture capture_exec);

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw( 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( 
);

our $VERSION = '0.0.0';

my $SBIN = "/usr/sbin";
my $COMMONOPTS = "--noheadings --separator : --units g --nosuffix";

sub new {
  my $class = shift;
  my $self = shift;

  unless( ref( $self ) ) {
    $self = {};
  }

  openlog( 'sanman', 'cons,pid', 'user' );
  #$self->{ "_SBIN"        } = \$SBIN;
  #$self->{ "_COMMONOPTS"  } = \$COMMONOPTS;
  bless( $self, $class );
  return $self;
}

sub strip { # strip whitespace from both ends of a string
  my $self = shift;
  my $returnval = shift;
 
  chomp($returnval);
  $returnval =~ s/^\s+//;
  $returnval =~ s/\s+$//;
  
  return $returnval;
}

sub execute_system_command { # executes a system command, returns success/fail
  my $self = shift;
  my $command = shift;
  my $stdout;
  my $stderr;
  #my $command = '/bin/bash -l -c "' . $self->strip(shift) . '"';
  syslog( 'info', "Attempting to run '$command'" );
  ($stdout,$stderr) = capture_exec( $self->strip( $command ) );
  my $return = $? >> 8;
  if($return) {
    my @lines = split( /\n/, $stderr );
    for my $line (@lines) {
      syslog("info", $self->strip($line));
    }
  } else {
    my @lines = split( /\n/, $stdout );
    for my $line (@lines) {
      syslog("info", $self->strip($line));
    }
  }
  syslog("info", "Return code was '$return'.");

  return { 'stdout' => $stdout, 'stderr' => $stderr, 'code' => $return };
}

sub sbin {
  return $SBIN;
}

sub commonopts {
  return $COMMONOPTS;
}

sub read_config {
  my $config;
  open( CONFIG, "</etc/sanman.conf");
  $config = join('', <CONFIG> );
  close( CONFIG );
  return from_json( $config );
}

1;
__END__

=head1 NAME

Sanman - Sanman is a San Management suite

=head1 SYNOPSIS

The Sanman module should never be loaded directly, really.

=head1 DESCRIPTION

This module provides common methods and variables to the other Sanman
modules.

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
