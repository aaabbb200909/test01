#!/bin/bash

####
#
# rsyncdest.sh:
#
# Multiple backup src:
# You can give multiple srcdir to backup.
# Before you add backupsrc, you should create directory under the destpath, whose name should be md5 hash of destpath.
# Use 
#  $ echo "${srcpath}" | md5sum
# Note:
#  If destpath is local, script can create directory automatically.
#
####


######Configuration
srcpaths="localhost::srcpath /home/tatsuya/perlgmetric /var/log/sa" # filepath or remotehost::filepath, you can give multiple paths 
##
##
destpath=/var/tmp/backups # filepath or remotehost::filepath, you can give only one destpath
dayoffullbackup=1 #0-6 (0 for Sunday, 6 for Saturday)
backupgeneration=1 # 1 or 2: backups are kept for ${backupgeneration} weeks
numoffullbackups=1 # 1 or 2: if 1, full backup should be nearly equal with incremental backup. if you set 2 for this, backupgeneration also should be 2.
bwlimit=0 # Default: 0
##
##
dayoftheweek="" # It normally should be empty. When you perform debug or recovery, please set 0-6
modforwhichdate="" # It normally should be empty. When you perform debug or recovery, please set 0,1
######

####Main

####
#set -x
export LANG=C
####
echo "Backup Date: $(date)"

if [[ ! ( 1 -eq $numoffullbackups || 2 -eq $numoffullbackups ) ]]
then
 echo "numoffullbackups should be 1 or 2"
 exit 34
fi

hostname=$(hostname)
whichdateinthisyear=$(date "+%W") # 0-366

if [[ -z ${dayoftheweek} ]]
then
 dayoftheweek=$(date "+%w" )
fi
if [[ -z ${modforwhichdate} ]]
then
 modforwhichdate=$(( ${whichdateinthisyear} % 2 ))
fi

finallrc=0
rmodforwhichdate=$(( ( ${modforwhichdate} + 1) % 2 ))

lastfullbackupdate=0
if [[ ${dayoftheweek} -gt ${dayoffullbackup} ]]
then
 lastfullbackupdate=${modforwhichdate}
else
 lastfullbackupdate=${rmodforwhichdate}
fi
if [[ ${backupgeneration} -eq 1 ]]
then
 lastfullbackupdate=0
fi


numoffullbackupop=" --link-dest=../${rmodforwhichdate}${dayoffullbackup}"
if [[ ${numoffullbackups} -eq 2 || ${backupgeneration} -eq 1 ]]
then
 numoffullbackupop=""
fi

## check md5 beforehand
tmpmd5s=""
for srcpath in ${srcpaths}
do
 tmpmd5s="${tmpmd5s}"$(echo ${srcpath} | md5sum | awk '{print $1}')" "
done
echo ${tmpmd5s} | tr " " "\n"| sort | uniq -c | awk '{print $1}' | grep -q "[2-9]"
if [[ $? -eq 0 ]]
then
 echo "You gave me srcpaths with duplicate md5. I'll exit" 
 echo ${srcpaths}
 echo ${tmpmd5s}
 exit 48
fi



## Begin backup
for srcpath in ${srcpaths}
do
	srcpathmd5=$(echo ${srcpath} | md5sum | awk '{print $1}')

	echo $destpath | grep -q '::'
	if [[ $? -eq 0 ]]
	then
	 : # remote dest
	else
	 if [[ -e ${destpath}/${srcpathmd5} ]]
	 then
	  :
	 else
	  echo "Create dir for srcpath: ${srcpath}"
	  echo "dir: ${destpath}/${srcpathmd5}"
	  mkdir ${destpath}/${srcpathmd5}
	 fi
	fi


	echo "Start backup for ${srcpath}:"
	if [[ ${dayoftheweek} -eq ${dayoffullbackup} ]]
	then
	 echo "Peform full backup"
         set -x
	 cd / && rsync -azR --delete --bwlimit ${bwlimit} ${numoffullbackupop} ${srcpath} ${destpath}/${srcpathmd5}/${modforwhichdate}${dayoftheweek}/
	 re=$?
         set +x
	 if [[ 0 -ne $re ]]
	 then
	  echo "WARN: rsync gave non-zero return code"
	  finalrc=50
	 fi
	else
	 echo "Perform differential backup:"
         set -x
	 cd /  && rsync -azR --delete  --bwlimit ${bwlimit} --link-dest ../${lastfullbackupdate}${dayoffullbackup} ${srcpath} ${destpath}/${srcpathmd5}/${modforwhichdate}${dayoftheweek}/
	 re=$?
         set +x
	 if [[ 0 -ne $re ]]
	 then
	  echo "WARN: rsync gave non-zero return code"
	  finalrc=51
	 fi
	fi
done

if [[ 0 -eq ${finalrc} ]]
then
 echo "Backup Ended Successfully"
else
 echo "Backup gave unexpected result. Check errrorlog."
fi
exit $finallrc


