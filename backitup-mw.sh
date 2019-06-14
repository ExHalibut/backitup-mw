#!/bin/bash
# Script for Mediawiki backup
# Features and requirements:
#       - Database backup via mysqldump
#       - Static HTML copy of the wiki via DumpHTML extension
#               - https://www.mediawiki.org/wiki/Extension:DumpHTML
#       - File compression via zip
#       - Basic file encryption via zipcrypto
#       - Encrypted file transmission via LFTP
# Designed for use on Ubuntu 12.04 LTS server

# Variables
mwname=""        # The directory where the wiki index php file lives
backupdir=""        # Backup directory
mwdbname=""    # MySQL database
mwdbuser=""     # MySQL database username
mwdbpass=""   # MySQL database password
zippass=""        # Zip encryption password
ftpserver=""       # FTP server address
ftpuser=""     # FTP account username
ftppass="" # FTP account password

# Format datestamp
NOW=$(date +"%d")

# Cleanup previous backup
rm -R -f $backupdir/$mwname

# Static HTML backup
echo ""
echo "DumpHTML for $mwname"
date
echo "--------------------"
/usr/bin/php /var/www/$mwname/extensions/DumpHTML/dumpHTML.php -d $backupdir/$mwname -k monobook --group=sysop --force-copy

# Image backup
echo ""
echo "Image backup for $mwname"
date
echo "--------------------"
mkdir $backupdir/$mwname/images
cp -dR /var/www/$mwname/images/* $backupdir/$mwname/images

# Create database backup
echo ""
echo "MySQL backup for $mwname"
date
echo "--------------------"
/usr/bin/mysqldump -u $mwdbuser -p$mwdbpass $mwdbname > $backupdir/$mwname/$mwname-mysql-$NOW.sql

# Compression and basic encryption
echo ""
echo "Compression of backup for $mwname"
date
echo "--------------------"
/usr/bin/zip -e -P $zippass -r /$backupdir/$mwname-$NOW.zip $backupdir/$mwname

# Encrypted file transfer
echo ""
echo "Transfer of backup for $mwname"
date
echo "--------------------"
echo ""
/usr/bin/lftp -u $ftpuser,$ftppass $ftpserver <<EOF
put /$backupdir/$mwname-$NOW.zip
ls -la|grep $mwname-$NOW.zip
quit 0
EOF
echo ""

