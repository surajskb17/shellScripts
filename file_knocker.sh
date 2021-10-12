#!/bin/bash
source ~/.bashrc
knock_files()
{
mkdir -p $HOME/cleanup_logs/TEMPDIR
LOG_DIR=$1
LOG_TYPE=`echo $LOG_DIR |rev | cut -d"/" -f1 | rev`
DAYS=$2
cd $LOG_DIR
FFDIR=$HOME/cleanup_logs/TEMPDIR
FFLIST=$FFDIR/flist_raw
SDate=`date '+%Y%m%d'`
MDate=`date -d "$DAYS days ago" +%Y%m%d`
echo "Files Cleanup for ${LOG_TYPE}..." >> $FFDIR/deleted_$SDate.txt
ls > $FFLIST
cd $FFDIR
for file in `cat $FFLIST`
do
fdate=`date -r $LOG_DIR/$file`
Date=`date -d "$fdate" +%Y%m%d`
if [[ $Date -lt $MDate ]]
then
ls -U $LOG_DIR/$file | xargs rm
echo "Deleted "$LOG_DIR/$file >> $FFDIR/deleted_$SDate.txt 2>&1
fi
done
rm $FFLIST
tar --remove-files -zcf cleanup_${SDate}.tar.gz *_${SDate}.txt
}
if [ $# -ne 1 ]
then
echo "Please pass the configuration file knocker.conf ..."
exit 1
fi
while read record
do
rec=`echo $record | grep -v "^#"`
if [ ! -z "$rec" ]
then
arg1=`echo $record | cut -d" " -f1`
arg2=`echo $record | cut -d" " -f2`
echo $arg1 $arg2
knock_files $arg1 $arg2
fi
done < $1
