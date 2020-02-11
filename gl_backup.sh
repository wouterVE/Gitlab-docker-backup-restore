#!/bin/bash

#####################################################
#script to backup your gitlab installation in docker
#this backups the following:
#*database
#*uploads (attachments)
#*repositories (Git repositories data)
#*builds (CI job output logs)
#*artifacts (CI job artifacts)
#*lfs (LFS objects)
#*registry (Container Registry images)
#*pages (Pages content)

#tested & created on this environment:
#ubuntu 18.04
#docker 19.03.5
#Gitlab 12.6.4 CE

#Created by wouterVE 2020
#URL: https://github.com/wouterVE/Gitlab-docker-backup-restore
#
#####################################################

###VARIABLES###
#All lines starting with TODO have to be set before this script can run!
#Get current date
date=$(date +"%Y%m%d")
timestamp=$(date +"%H-%M")
backupname=$(echo "gitlab_config.zip")
cfgbackup="$date"_"$timestamp"_"$backupname"
#TODO If you have changed the backup path for gitlab adjust this variable accordingly(see https://docs.gitlab.com/omnibus/settings/backups.html#creating-an-application-backup)
gl_back_loc="/srv/gitlab/data/backups/"
#TODO  amount of DAYS to keep backup files eg 7
maxDaysOfBackups="7"
#TODO Gitlab config mount point (defaults to /srv/gitlab/config only change if you're using a different mount point)
gl_config="/srv/gitlab/config"
#OPTION If you choose to rsync the backup to an external storage (samba, webdav...) set the rsync location here
#!!IMPORTANT!!
#this path must end with an / for rsync to work correctly (but if you forgot there's a check anyway :-)
rsync_loc="/path/to/mount/point/"
#OPTION if you wish to backup your apache/nginx settings (eg reverse proxy) provide the location of the vhost
webserver=""
###END OF VARIABLES###

############################################################



#
# Check for root permissions
#
if [ "$(id -u)" != "0" ]
then
        echo "ERROR: This script has to be run as root!"
        exit 1
fi


#Creating strong password to store your config & ssh keys safely
#location of generated key is /home/gl

glpw_check=$(cat /home/gl | wc -c)
#echo $glpw_check
if [ "$glpw_check" -gt 44 ]
then
echo "password allready exists" > /dev/null
else
openssl rand -base64 32  > /home/gl #> /dev/null
#make sure only your user can access this file
chmod 400 /home/gl
fi
#Store strong password
glpw=$(cat /home/gl)

#
#Just making sure the rsync location ends with a /
#
rsync_check=$(echo $rsync_loc | rev | cut -c 1)
if [ "$rsync_check" != "/" ]
then
rsync_loc=$(echo $rsync_loc/)
fi


#Get docker container id 
containerid=$(docker ps | grep gitlab | awk '{ print $1}')
#Or alternatively you can use this (you'll need to change the tag if your not using the latest!
#(source: https://stackoverflow.com/questions/54098866/how-to-obtain-container-id-base-on-docker-image-name-via-command-line?noredirect=1)
#containerid=$(docker ps --filter "ancestor=gitlab/gitlab-ce:latest" -q) 

#Uncomment next line to see if the correct container ID is shown
#echo $containerid

#
#First we create a backup of the gitlab data WITHOUT config files nor SSH keys 
#See official documentation
# https://docs.gitlab.com/ee/raketasks/backup_restore.html
# https://docs.gitlab.com/omnibus/settings/backups.html
# FYI: Default backup location = /srv/gitlab/data/backups
docker exec -t "$containerid" gitlab-backup create BACKUP="$date""_""$timestamp" GZIP_RSYNCABLE=yes #default backup option comment this when using other option
# If you receive error "File changed as we read it" you can add "STRATEGY=copy"
# If so comment first line and uncomment next
# docker exec -t "$containerid" gitlab-backup create STRATEGY=copy BACKUP="$timestamp"  GZIP_RSYNCABLE=yes #uncomment this line when errors with default option 
# see https://docs.gitlab.com/ee/raketasks/backup_restore.html#backup-strategy-option


#
# backup config data 
# using the password generated and stored in /home/gl
#

zip -r --password "$glpw" $gl_back_loc"$cfgbackup"  $gl_config >/dev/null


#
# create dir for the date at remote location
# first check if already exists
#
if [ -d "$rsync_loc$date" ]
then
echo "Directory already exists" > /dev/null
else
mkdir $rsync_loc$date
fi

#
#OPTION -> if you wish to backup your webserver settings (eg reverse proxy) set up webserver path in variables
#backup webserver settings
#
if [ -z "$webserver" ]
then
echo "Nothing to do" > /dev/null
else
echo "ok"
zip $rsync_loc$date/$date"_"$timestamp"_webserver.zip" $webserver

fi

#
# OPTION -> if you want to save your backups to remote location uncomment the following lines
# and fill in rsync_loc variable.
# If you opt not to rsync, make sure you fill in the 'backup_keep-time' variable in gitlab.rb
# to remove old backups
# see https://docs.gitlab.com/ee/raketasks/backup_restore.html#configuring-cron-to-make-daily-backups
#
# rsync the backup to remote location
###rsync -aP --remove-source-files $gl_back_loc $rsync_loc$date

#
# Delete old backups
#
#if (( ${maxDaysOfBackups} != 0 ))
#then
#	nrOfBackups=$(ls -l ${rsync_loc} | grep -c ^d)

#	if (( ${nrOfBackups} > ${maxDaysOfBackups} ))
#	then
#		echo "Removing old backups..."
#		ls -t ${rsync_loc} | tail -$(( nrOfBackups - maxDaysOfBackups )) | while read dirToRemove; do
#		echo "${dirToRemove}" 
#		rm -r ${rsync_loc}"${dirToRemove}"
#		echo "Done"
#		echo
#    done
#	fi
#fi

##############################################
