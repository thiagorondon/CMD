use strict;
use warnings;
use Config::Any;

my $config = Config::Any->load_files( { files => [ 'db_config.json' ], use_ext => 5 } );

dbicadmin -Ilib --schema CMD::Schema \
	--connect='[ $config->[0]{ 'db_config.json' }->{ db_config }->{ dsn } , $config->[0]{ 'db_config.json' }->{ db_config }->{ password }, $config->[0]{ 'db_config.json' }->{ db_config }->{ user }]' \
	--deploy
