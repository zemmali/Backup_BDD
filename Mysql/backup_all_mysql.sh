#!/bin/sh
# System + MySQL backup script
# Saddam ZEMMALI 
# IT Infrastructure Engineer
# ---------------------------------------------------------------------

#########################
######TO BE MODIFIED#####

### System Setup ###
BACKUP=YOUR_LOCAL_BACKUP_DIR

### MySQL Setup ###
MUSER="MYSQL_USER"
MPASS="MYSQL_USER_PASSWORD"
MHOST="localhost"

### FTP server Setup ###
FTPD="YOUR_FTP_BACKUP_DIR"
FTPU="YOUR_FTP_USER"
FTPP="YOUR_FTP_USER_PASSWORD"
FTPS="YOUR_FTP_SERVER_ADDRESS"

######DO NOT MAKE MODIFICATION BELOW#####
#########################################

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
FTP="$(which ftp)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date +"%d%H")

### Create hourly dir ###

mkdir $BACKUP/$NOW

### Get all databases name ###
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do

### Create dir for each databases, backup tables in individual files ###
  mkdir $BACKUP/$NOW/$db

  for i in `echo "show tables" | $MYSQL -u $MUSER -h $MHOST -p$MPASS $db|grep -v Tables_in_`;
  do
    FILE=$BACKUP/$NOW/$db/$i.sql.gz
    echo $i; $MYSQLDUMP --add-drop-table --allow-keywords -q -c -u $MUSER -h $MHOST -p$MPASS $db $i | $GZIP -9 > $FILE
  done
done

### Compress all tables in one nice file to upload ###

ARCHIVE=$BACKUP/$NOW.tar.gz
ARCHIVED=$BACKUP/$NOW

$TAR -cvf $ARCHIVE $ARCHIVED

### Dump backup using FTP ###
cd $BACKUP
DUMPFILE=$NOW.tar.gz
$FTP -n $FTPS <<END_SCRIPT
quote USER $FTPU
quote PASS $FTPP
cd $FTPD
mput $DUMPFILE
quit
END_SCRIPT

### Delete the backup dir and keep archive ###

rm -rf $ARCHIVED
