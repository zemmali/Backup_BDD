#!/bin/bash
NOW="$(date +"%B_%Y")"
NOW2="$(date +"%F")"
NOW1="$(date +"%F_%H%M")"
DIR="/home/backup/bdd"

#### Backup BDD postgresql
echo "$NOW1 Backup BDD postgresql du $(date +"%B_%Y")" > $DIR/backup-bdd.log


pg_dump -d postgresql  | bzip2 > $DIR/backup_bdd_postgresql.$NOW2.psql.bz2


if [ $? -ne 0 ]
then
       echo "$NOW1 : Backup BDD postgresql Reponses NOK" >> $DIR/backup-bdd.log
else
       echo "$NOW1 : Backup BDD postgresql Reponses OK" >> $DIR/backup-bdd.log
fi


# Sending Backup to SFTP Server
HOST=
USER=
PASS=


echo "$NOW1 : Starting to send backup..." >> $DIR/backup-bdd.log
lftp -u ${USER},${PASS} sftp://${HOST} > $DIR/test_tranfert-bdd.log <<EOF
cd   postgresql/bdd
put  $DIR/backup_bdd_postgresql.$NOW2.psql.bz2
bye
EOF

echo "Transfert done"  >> $DIR/backup-bdd.log
rm $DIR/backup_bdd_postgresql.$NOW2.psql.bz2

# Verifier s.il existe des erreurs lors du transfert
err_ftp=`egrep -c '(Could not create file.|Login incorrect.|Not connected.)' $DIR/test_tranfert-bdd.log`
if [ $err_ftp -eq 0 ]
then
       echo "$NOW : Transfert OK" >> $DIR/backup-bdd.log
       
else
       echo "$NOW : Transfert NOK" >> $DIR/backup-bdd.log
       cat $DIR/test_tranfert-bdd.log >> $DIR/backup.log
fi
