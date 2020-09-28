#!/bin/bash
#call addoratab case new instance
su - oracle -c /home/oracle/addoratab.sh
#call reconfig (if new instance added)
su - oracle -c /home/oracle/confveor.sh
#call backup script
su - oracle -c /home/oracle/backup.sh
