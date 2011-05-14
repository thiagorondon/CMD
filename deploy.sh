
#rm cmd-novo.db

#dbicadmin -Ilib --schema CMD::Schema \
#	--connect='["dbi:SQLite:dbname=cmd-novo-2009.db", "", ""]' \
#	--deploy

dbicadmin -Ilib --schema CMD::Schema \
	--connect='["dbi:mysql:db=cmd", "cmd", "aviao"]' \
	--deploy

#dbicadmin -Ilib --schema CMD::Schema \
#	--connect='["dbi:Pg:db=cmd", "thiago", ""]' \
#	--deploy


