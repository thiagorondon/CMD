#!/bin/sh

/bin/fuser -k 8108/tcp
sleep 2

/var/lib/jenkins/jobs/CMD/workspace/script/cmd_fastcgi.pl -l :8108 -n 5 -d


