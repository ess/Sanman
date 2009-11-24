use inc::Module::Install;

name 'Sanman';
all_from 'lib/Sanman.pm';
requires 'JSON::RPC::Server' => '0.92';
requires 'JSON::RPC::Client' => '0.93';

WriteAll;
