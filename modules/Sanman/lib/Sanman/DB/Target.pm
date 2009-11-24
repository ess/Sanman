package Sanman::DB::Target;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'initiators' );
__PACKAGE__->add_columns( qw/id name targetname description/ );
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->has_many( map_allowed_targets => 'Sanman::DB::InitTarget', 'target_id' );
__PACKAGE__->many_to_many( initiators => 'map_allowed_targets', 'initiator' );

1;

