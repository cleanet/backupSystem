![[Pasted image 20230108163434.png]]

[Introduction](https://github.com/cleanet/backupSystem#introduction)
[files distribution](https://github.com/cleanet/backupSystem#how_it_works)
[Implementation and configuration](https://github.com/cleanet/backupSystem#implementation_configuration)
[License](https://github.com/cleanet/backupSystem#license)
[Contact](https://github.com/cleanet/backupSystem#contact)

## Introduction
This project is a little backup system very simple, made in Bash scripting.
Where you executes the file script `start.sh` and it generates a compressed file in `tar.gz2` with all data.

After the script upload the compressed file to your MEGA account

## files distribution
`config.yaml`: YAML configuration file, where it specify the data that will be store the backup file.
`start.sh`: main script for generate the backup file.

## Implementation and configuration
First you go to directory where you want store the backup and clone the repository. For this example in `/etc/`
Run:
```
# cd /etc/
/etc# git clone https://github.com/cleanet/backupSystem
```

The main script requires the `BACKUPSYSTEM_PATH` environment variable. It is the path where is the repository cloned.
We go to create it:
```
# echo "BACKUPSYSTEM_PATH=/etc/backupSystem" >> /etc/environment
# export BACKUPSYSTEM_PATH=/etc/backupSystem
```

The `/etc/environment` file is for create the environment file permanently. And the `export` command for create it right now.

In the YAML configuration file `config.yaml`,  you must be edit the keys under of the comment `# backupSystem` by the environment variable value `BACKUPSYSTEM_PATH`. The value must be the same.
![[Pasted image 20230108181752.png]]

### MEGA commad
For configure the mega command you must login you in you mega account:
```
mega-login <email> <password>
```

After run again the command `mega-login`, if you are logged, this will show
```
[API:err: 18:17:02] Already logged in. Please log out first.
```
This is permanent, this process isn't necessary for use the main script `start.sh`

### YAML configuration file
```
backup:
  source: backup
  destination: backups
data:
  copy:
    # backupSystem
    - source: /etc/backupSystem/start.sh

    - source: /etc/backupSystem/config.yaml

    # FTP
    - source: /etc/vsftpd.conf
    - source: /etc/users_vsftpd.deny

    # HTTP
    - source: /etc/apache2

    # nextcloud
    - source: /nextcloud
    - source: /home/nextcloud
      destination: nextcloud_data

    # DNS
    - source: /etc/bind

    - source: /etc/fstab

    - source: /etc/crontab

    # OTP
    - source: /etc/security/access-oath.conf
```

* `.backup.source`
Specifies the directory where will copy all the data.  The value is `backup`, means that the data will be copy to the directory `/etc/backupSystem/backup/`. Is `/etc/backupSystem` because is the value of environment variable `BACKPSYSTEM_PATH`

* `.backup.destination`
Specifies the directory where will store the compressed file .tar.gz2

* `.data.copy`
This key contains a objects array, where each object is the data source that will copy at backup file.
Each object contains the keys following:
* `source`: This key specifies the source data for copy it at backup file. For example:
```
 - source: /etc/apache2
```
The object described up, means that all the content of `/etc/apache2` will be copied to `/etc/backupSystem/backup/`. 
And you will ask you, Where come the path `/etc/backupSystem/backup/` ? This path comes of value of destination key (`.backup.destination`) concated with destination folder name

* `destination`: This key is optional. Specifies the destination folder created in `$backupSource` for store the data of key `source`. Example:
```
- source: /nextcloud

- source: /home/nextcloud
  destination: nextcloud_data
```

Here there are two objects. The first object, copy the path `/nextcloud` to `/etc/backupSystem/backups/`. In `/etc/backupSystem/backups/` would generate this path `/etc/backupSystem/backups/nextcloud`

In the second object, copy the path `/home/nextcloud` to `/etc/backupSystem/backups/`. In `/etc/backupSystem/backups/` would generate the path `/etc/backupSystem/backups/nextcloud`, but as this object has the key `destination`, this would generate `/etc/backupSystem/backups/nextcloud_data`. For not overwrite the path `/etc/backupSystem/backups/nextcloud` already existing. So we can store the two data.

So in the main script in the function `copyFiles()` after of  'for loop', I added the command `mysqldump --all-databases >> $backupSource/databases.sql` for do a backup of databases

## License
This project is licensed by the GPLv3 (GNU Public License version 3)

## Contact
Cleanet: cleannet29@gmail.com
