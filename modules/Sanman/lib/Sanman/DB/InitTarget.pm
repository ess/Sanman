package Sanman::DB::InitTarget;
use base qw/DBIx::Class/;
__PACKAGE__->load_components( qw/PK::Auto Core/ );
__PACKAGE__->table( 'initiators_targets' );
__PACKAGE__->add_columns( qw/ target_id initiator_id/ );
__PACKAGE__->belongs_to( target => 'Sanman::DB::Target', 'target_id' );
__PACKAGE__->belongs_to( initiator => 'Sanman::DB::Initiator', 'initiator_id' );

1;

