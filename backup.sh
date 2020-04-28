#!/bin/bash
dt=$(date +%Y-%m-%d)
SCRIPTPATH=$(cd ${0%/*} && pwd -P)
BACKUP_DIR=$SCRIPTPATH/archive/
TMP_DIR=$SCRIPTPATH/tmp/
LST_FILE=$SCRIPTPATH/backup.lst
MONTHS_TO_KEEP=3
WEEKS_TO_KEEP=4
DAYS_TO_KEEP=6
DAY_OF_MONTH=`date +%d` #1-31
DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if ! mkdir -p $TMP_DIR; then
	echo "Cannot create temp directory in $TMP_DIR. Go and fix it!" 1>&2
	exit 1
fi

echo Backup starting...

# https://www.tldp.org/LDP/abs/html/comparison-ops.html
# https://stackoverflow.com/questions/3826425/how-to-represent-multiple-conditions-in-a-shell-if-statement
# START THE BACKUPS
perform_backups()
{
	EXPIRED_DAYS=50
	SUFFIX=$1
	ALLOWALSO=$2
	FINAL_BACKUP_DIR=$BACKUP_DIR"`date +\%Y-\%m-\%d`-$SUFFIX/"
	
	if [ "$SUFFIX" = "d" ]; then
		EXPIRED_DAYS=$DAYS_TO_KEEP
	fi
	if [ "$SUFFIX" = "w" ]; then
		EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`
	fi
	if [ "$SUFFIX" = "m" ]; then
		EXPIRED_DAYS=`expr $((($MONTHS_TO_KEEP * 31) + 1))`
	fi
	
	echo Remove old backups...
	find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-$SUFFIX" -exec echo '  {}' ';' -exec rm -rf '{}' ';'
	
	echo destinaton: $FINAL_BACKUP_DIR
	echo 
	mkdir -p $FINAL_BACKUP_DIR
	#cd $FINAL_BACKUP_DIR
	cd $TMP_DIR

	cat $LST_FILE | while read line
	do
		FIRST_CHAR="${line:0:1}"
		
		if [[ "$ALLOWALSO" != "" && "$FIRST_CHAR" = "$ALLOWALSO" ]]; then
			line="${line:1}"
			FIRST_CHAR="${line:0:1}"
		fi
		if [ "$FIRST_CHAR" = "/" ]; then
			cp -f -r -p --parents $line .
		fi		
		
		if [ "$FIRST_CHAR" = "D" ]; then
			mkdir -p $TMP_DIR${line:2}
		fi		
		
		if [ "$FIRST_CHAR" = "-" ]; then
			rm -rf $TMP_DIR${line:2}
		fi		
		
		if [ "$FIRST_CHAR" = "!" ]; then
			${line:1}
		fi		
	done
	
	mv -f *.tgz $FINAL_BACKUP_DIR
	echo Archiving...
	tar -cz  -f sources.tgz .
	mv -f *.tgz $FINAL_BACKUP_DIR
	rm -rf $TMP_DIR*
	
	echo Done!
}

if [ "$1" = "" ]; then
	echo "BackUP.sh - backup whole system."
	echo "  use backup.lst to set-up the process"
	echo "usage backup.sh d|w|m ["""*""" or another special char]"
	echo "  d - days"
	echo "  w - weeks"
	echo "  m - month"
	echo "  a - auto: 1 day of week - w *, first day of month m *, else d"
	echo "  you can use any another char"
	echo "  "*" or another special char - also execute string staring from that char"
	echo 
	echo "you must use cron to determine your exactly schedule"
else
	if [ "$1" = "a" ]; then
		if [ $DAY_OF_MONTH -eq 1 ]; then
			perform_backups "m" "*"
			exit 0;
		fi
		if [ $DAY_OF_WEEK -eq 1 ]; then
			perform_backups "w" "*"
			exit 0;
		fi
		perform_backups "d" "$2"
	else
		perform_backups "$1" "$2"
	fi
fi

#perform_backups "w" "*"
#perform_backups "d"

exit