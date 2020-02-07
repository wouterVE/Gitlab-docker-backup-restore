# Gitlab-docker-backup-restore
Scripts  to backup &amp; restore your Gitlab docker installation
For Gitlab docker installation see  <a href="https://docs.gitlab.com/omnibus/docker/"> this link </a> 

# Backup
Run `gl_backup.sh` as root in order to create a backup 
Before you begin, make sure you check the following:

1-`openssl`, `zip`, `rsync` need to be installed. If not, use the package manager of your distro to install them <br>
2-Some variables need to be set up first. 
Every line starting with `TODO`needs your input. Lines with `OPTION` are optionally <br>
3-Consider reading the documentation at Gitlab first. Check <a href="https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-for-omnibus-installations"> this </a> and <a href="https://docs.gitlab.com/omnibus/settings/backups.html">this</a> as well
<p>
 

