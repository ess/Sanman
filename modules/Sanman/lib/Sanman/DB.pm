package UatuDB;
use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_classes(qw/Tasks Clients Ilines Issues Servers/);

1;

