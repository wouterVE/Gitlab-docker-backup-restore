#!/bin/bash


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
#Folder to restore (entered in command line)
restore_folder=$1

#TODO backup location
# Enter the location for your backup files (either locally of external rsync location
#bac_loc="/path/to/backup"

#OPTION If you have changed the backup path for gitlab adjust this variable accordingly(see https://docs.gitlab.com/omnibus/settings/backups.html#creating-an-application-backup)
gl_back_loc="/srv/gitlab/data/backups"
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
(hint: you can view the exact version in the file backup_information.yml located in DATE&TIMESTAMP_gitlab_backup.tar)"
echo -n "Press any key to continue" 
read 

#COPY BACKUP FILES

if [ -z "$restore_folder"  ]
then
echo "Please enter backup folder to restore!"
echo "exiting..."
exit 1
else

if [ ! -d "$bac_loc"/"$restore_folder" ]
then
echo "Restore folder does not exist!"
exit 1
fi
echo "copying files to $gl_back_loc"
cp -an "$bac_loc"/"$restore_folder"/. "$gl_back_loc"

fi






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

backup_config=$(ls -t "$gl_back_loc"/*_gitlab_config* | tail -n 1)
unzip -o "$backup_config" -d /





#Restoring web config
while true; do
    read -rp "Do you wish to restore the web configuration? (y/N)" yn
    case $yn in
        [Yy]* ) echo "restoring web config...";webconfig=$(ls -t "$gl_back_loc"/*_webserver* | tail -n 1); unzip "$webconfig" -d /; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done



echo "Everything is retored.."
exit 1





