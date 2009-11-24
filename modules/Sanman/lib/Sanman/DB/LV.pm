package Sanman::DB::LV;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'lvs' );
__PACKAGE__->add_columns( qw/id name description gsize vg_id/ );
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->belongs_to( vg => 'Sanman::DB::VG', 'vg_id' );

1;

