package Sanman::DB::Initiator;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'initiators' );
__PACKAGE__->add_columns( qw/id name ipn/ );
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->has_many( map_allowed_targets => 'Sanman::DB::InitTarget', 'initiator_id' );

1;

