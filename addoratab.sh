original="#\n\n\n\n# This file is used by ORACLE utilities.  It is created by root.sh\n# and updated by either Database Configuration Assistant while creating\n# a database or ASM Configuration Assistant while creating ASM instance.\n\n# A colon, ':', is used as the field terminator.  A new line terminates\n# the entry.  Lines beginning with a pound sign, '#', are comments.\n#\n# Entries are of the form:\n#   $ORACLE_SID:$ORACLE_HOME:<N|Y>:\n#\n# The first and second fields are the system identifier and home\n# directory of the database respectively.  The third field indicates\n# to the dbstart utility that the database should , "Y", or should not,\n# "N", be brought up at system boot time.\n#\n# Multiple entries with the same $ORACLE_SID are not allowed.\n# \n# \n"
path="/u01/app/19.0.0/grid/bin/crsctl"
cat /dev/null > /etc/oratab
printf "$original" >> /etc/oratab

for resource in $($path status resource -w "((TYPE = ora.database.type) AND (LAST_SERVER = $(hostname -s)))" | grep ^NAME | sed 's/.*=//'); do
    full_resource=$($path status resource -w "((NAME = $resource) AND (LAST_SERVER = $(hostname -s)))" -f)
    db_name=$(echo "$full_resource" | grep ^DB_UNIQUE_NAME | awk -F= '{ print $2 }')
    ora_home=$(echo "$full_resource" | grep ^ORACLE_HOME= | awk -F= '{ print $2 }')
    instance="1"
    oracle="$db_name$instance:$ora_home:N \n"    
    printf "$oracle" &>> /etc/oratab
done
