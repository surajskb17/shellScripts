#!/bin/bash
source ~/.bashrc
logger()
{
	echo "`date +'%Y%m%d %H:%M:%S.%3N'` [CommonLogger] [`echo $0 | cut -d"." -f1 | tr -d "_"`] $1"
}
if [ $# -ne 6 ]
then
	logger "Please pass the Input Path, InputTouch Path, Move Path, TempPath for Unzip, Working Directory, Filename Pattern"
	exit 1
fi
INPTH=$1
INTCH=$2
MVPTH=$3
TMPTH=$4
WRKDR=$5
FPATT=$6
TMPWRKINGFIL=${WRKDR}/heigo_files.txt
while true
do
	> $TMPWRKINGFIL
	logger "Starting pulling files to buffer..."
	cd $INTCH
	FCNT=`ls -U | wc -l`
	if [ $FCNT -gt 0 ]
	then
		ls -U | grep ${FPATT} | head -1000 > ${WRKDR}/heigo_list.txt
		rm -f `cat ${WRKDR}/heigo_list.txt`
		cd ${INPTH}
		cat ${WRKDR}/heigo_list.txt | while read file
		do
			mv $file $TMPTH/
			if [ $? -ne 0 ]
			then
				logger "Aborting as file movement failed for $file"
				exit 1
			fi
		done
		logger "Moved `wc -l ${WRKDR}/heigo_list.txt | awk '{print $1}'` files in buffer..."
		cd $TMPTH
		cat ${WRKDR}/heigo_list.txt | xargs gunzip
		logger "G-Unzipped the files in buffer..."
		ls -U | grep ${FPATT} | xargs cat > ${WRKDR}/tempfile
		rm -f $TMPTH/*${FPATT}*
		mv ${WRKDR}/tempfile $TMPTH/
		DTT=`date +%Y%m%d%H%M%S%3N`
		split -a 4 -l 50000 -d tempfile ${FPATT}_${DTT}_
		logger "Splits performed..."
		rm -f $TMPTH/tempfile
		ls -U | grep "${FPATT}_${DTT}" | while read file
		do
			mv $file $MVPTH
			if [ $? -ne 0 ]
			then
				logger "Aborting as file movement failed for $file"
				exit 1
			fi
			touch $MVPTH/$file
		done
		logger "Moved all files from $TMPTH to $MVPTH ... Processing done..."
	else
		logger "No files found..."
	fi
	logger "Sleeping for 5 seconds..."
	sleep 5
done
