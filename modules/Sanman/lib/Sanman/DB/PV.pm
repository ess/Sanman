package Sanman::DB::PV;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'pvs' );
__PACKAGE__->add_columns( qw/id name vg_id/ );
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->belongs_to( vg => 'Sanman::DB::VG', 'vg_id' );

1;

