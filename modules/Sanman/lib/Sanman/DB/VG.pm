package Sanman::DB::VG;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'vgs' );
__PACKAGE__->add_columns( qw/id name description/ );
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->has_many( pvs => 'Sanman::DB::PV', 'vg_id' );

1;

