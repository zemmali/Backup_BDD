# This script will create a backup of each table in every database (one file per table), compress it and upload it to a remote ftp.



### Be aware, that in order to execute this script from cron, you need to store password in it (so cron won’t be prompted to provide a password). That’s why, you should not use a root account. Instead just create a new user only for backups, with following privileges:


- SHOW DATABASES
- SELECT
- LOCK TABLES
- RELOAD


### Create daily cronjobs in /etc/crontab. The backup runs daily at 1am.

m h dom mon dow user command

0 1 * * *  /var/scripts/backup_all_mysql.sh