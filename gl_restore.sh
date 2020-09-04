#!/bin/bash

#####
#Bug#
#####

#line 162
#Question "Do you want to copy the latest file from backup location? (y/N)"
#Loop when answering "N"
#Comment the section if you don't want to restore webserver config 


#####################################################
#script to restore your gitlab installation in docker
#use in combination with gl_backup.sh

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

#TODO If you have changed the backup path for gitlab adjust this variable accordingly(see https://docs.gitlab.com/omnibus/settings/backups.html#creating-an-application-backup)
gl_back_loc="/srv/gitlab/data/backups"
#OPTION: if you have chosen to rsync your backups please provide tha same path here
rsync_loc="/path/to/mount/point"
###END OF VARIABLES###

#####################################################

# Perform some checks


#
# Check for root permissions
#
if [ "$(id -u)" != "0" ]
then
        echo "ERROR: This script has to be run as root!"
        exit 1
fi

#
# Check for syntax shell call
#
## -> TODO


echo -e "THESE STEPS NEED TO BE EXECUTED TO RESTORE YOUR GITLAB INSTALLATION
PLEASE READ CAREFULLY BEFORE PROCEEDING \n
1-Stop your current docker container ($ sudo docker stop <CONTAINER NUMBER> 
2-Remove/rename your mount point directory (default:/srv/gitlab)
3-Starting new container with the same WITH THE SAME GITLAB VERSION
(hint: you can view the exact version in the file backup_information.yml located in DATE&TIMESTAMP_gitlab_backup.tar)
4-[OPTION]:Copy the following files under the backup folder (default location on host = /srv/gitlab/data/backup)
Important: do not use subfolders! 
The following files must be present:
-DATE&TIMESTAMP_gitlab_backup.tar
-DATE&TIMESTAMP_gitlab_config.zip
Optionally:
-DATE&TIMESTAMP_webserver.zip
If you skip this skip the latest backup will be copied automatically"
echo -n "Pres any key to continue" 
read 

#check if files are present
#source: https://stackoverflow.com/questions/6363441/check-if-a-file-exists-with-wildcard-in-shell-script

#backup files

if ls $gl_back_loc/*_gitlab_backup*   1> /dev/null 2>&1; then

echo "Gitlab backup present"
else
echo "Error Gitlab backup is NOT present!"
if [ -z "$rsync_loc" ]
then
echo "No rsync_loc - pleasy copy backup files manually!";exit 1
else
while true; do
    read -rp "Do you want to copy the latest file from backup location? (y/N)" yn
    case $yn in
        [Yy]* )
backup_file=$(find  $rsync_loc -name "*_gitlab_backup*" | tail -n 1)
if [ -z "$backup_file" ]
then
echo "Error file not found!"; exit 1
else
echo "Copying backup file..."
cp "$backup_file" "$gl_back_loc" 
fi
#check
break;;[Nn]* ) echo "OK please copy file manually";echo "exiting now..";exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

fi

fi
echo

#config files

if ls $gl_back_loc/*_gitlab_config* 1> /dev/null 2>&1; then

echo "Gitlab config present"
else
echo "Error Gitlab config is NOT present!"
if [ -z "$rsync_loc" ]
then
echo "No rsync_loc - pleasy copy backup files manually!";exit 1
else
while true; do
    read -rp "Do you want to copy the latest file from backup location? (y/N)" yn
    case $yn in
        [Yy]* )
config_file=$(find  $rsync_loc -name "*_gitlab_config*" | tail -n 1)
if [ -z "$config_file" ]
then
echo "Error file not found!"; exit 1
else
echo "Copying backup file..."
cp "$config_file" "$gl_back_loc"
fi
break;;[Nn]* ) echo "OK please copy file manually";echo "exiting now..";exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

fi

fi

echo

#webserver files
######
#BUG:#
######
#Answering no to "Do you want to copy the latest file from backup location? (y/N)"
#results in loop
#please comment section below if you don't want to restore webconfig 
#Starting from
#BEGIN COMMENTING
if ls $gl_back_loc/*_webserver* 1> /dev/null 2>&1; then

echo "Gitlab webserver present"
else
echo "Error gitlab webserver config is not present!"
if [ -z "$rsync_loc" ]
then
echo "No rsync_loc - pleasy copy backup files manually!";exit 1
else
while true; do
    read -rp "Do you want to copy the latest file from backup location? (y/N)" yn
    case $yn in
        [Yy]* )
webserver_file=$(find  $rsync_loc -name "*_webserver*" | tail -n 1)
if [ -z "$webserver_file" ]
then
echo "Error file not found!"; exit 1
else
echo "Copying backup file..."
cp "$webserver_file" "$gl_back_loc"
fi

break;;[Nn]* ) echo "OK skipping copy..";;
        * ) echo "Please answer yes or no.";;
    esac
done

fi

fi

###END COMMENTING


echo
echo
echo "Restoring gitlab..."
echo "Answer yes to the 2 questions regarding restoring database & config"
echo "press any key to continue"
read 
#backup_gitlab=$(ls -t $gl_back_loc/*_gitlab_backup* | tail -n 1)
#Get docker container id
containerid=$(docker ps | grep gitlab | awk '{ print $1}')
docker exec -it "$containerid" gitlab-backup restore


echo
echo
echo "Restoring config - enter your password when asked for it..."

backup_config=$(ls -t $gl_back_loc/*_gitlab_config* | tail -n 1)
unzip -o "$backup_config" -d /





#Restoring web config
while true; do
    read -rp "Do you wish to restore the web configuration? (y/N)" yn
    case $yn in
        [Yy]* ) echo "restoring web config...";webconfig=$(ls -t $gl_back_loc/*_webserver* | tail -n 1); unzip "$webconfig" -d /; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done



echo "Everything is retored.."
exit 1





