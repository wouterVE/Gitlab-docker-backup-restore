# Gitlab-docker-backup-restore
Scripts  to backup &amp; restore your Gitlab docker installation
For Gitlab docker installation see  <a href="https://docs.gitlab.com/omnibus/docker/"> this link </a> 

# Backup
Run `gl_backup.sh` as root in order to create a backup 
Before you begin, make sure you check the following:

1. `openssl`, `zip`, `rsync` need to be installed. If not, use the package manager of your distro to install them <br>
2. Some variables need to be set up first. 
Every line starting with `TODO`needs your input. Lines with `OPTION` are optionally <br>
3. Consider reading the documentation at Gitlab first. Check <a href="https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-for-omnibus-installations"> this </a> and <a href="https://docs.gitlab.com/omnibus/settings/backups.html">this</a> as well
<p>
 
The standard backup location is `/srv/gitlab/data/backups`. You can choose to move your backups to a remote location. If you want this, uncomment the last lines and make sure you enter a remote location (eg `/mnt/samba`) for the variable `rsync_loc`.
After the backup has been succesfully created, `rsync` will be used to move the files to your remote location.
 
 The backup is saved in a directory with the date eg `YYYYMMDD` with the following names:
  * `YYMMDD_HH_MM_gitlab_backup.tar`: the main backup of your gitlab installation (repositories, db...)
 * `YYMMDD_HH_MM_gitlab_config.zip`: the configuration of your gitlab installation, protected with the password saved in `/home/gl`
 * `YYMMDD_HH_MM_webserver.zip`: optionally the configuration for your webserver (eg if you use one for reverse proxy)

## Important note
The configuration data contains the encryption keys to protect the following sensitive data in the SQL database:
* 2FA user secrets
* CI Secure variables

As such it is advised to not store the config backup next to your data backup. I've opt to store them in the same place, but securing the config data with a strong password. This is generated upon the first backup and can be found under `/home/gl`. Make sure you take a note of this password.

## Schedule
You can schedule a backup job by setting a cronjob for the root user eg:
> 0 3 * * * /path/to/gl_backup.sh

# Restore
WIP
