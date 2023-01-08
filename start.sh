#!/bin/sh
# author: cleanet
# cleannet29@gmail.com
#
# Licensed by GNU GENERAL PUBLIC LICENSE VERSION 3
# This file is part of backupSystem
# backupSystem is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# backupSystem is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with ClassAdmin. If not, see <https://www.gnu.org/licenses/>.
# Copyright 2023 cleanet
#
# This script file is responsible of generate a backup of all data specified by its YAML configuration file.
#

# syntax: readYaml <path> <quotes:boolean>
readYaml() {
	output=`yq $1 /etc/backupSystem/config.yaml`
	if [ $2 -eq 1 ];then
		output=`echo "$output" | sed "s|\"||g"`
		echo "$output"
	else
		echo "$output"
	fi
}

parent=`readYaml .parent 1`
backupSource=`readYaml .backup.source 1`
backupDestination=`readYaml .backup.destination 1`
date=`date "+%d-%m-%Y"`

echo "======================================"
echo "      BACKUP backup_$date.tar.gz      "
echo "======================================"

# utils
log() {
	datetime=`date "+%H:%M:%S"`
        echo "$date $datetime $1" >> $parent/backups/backup_$date.log

}

print() {
	log $1
        printf "$1..."
}

copy() {
	print "copying $1 to $backupSource/$2"
	rsync -a --delete $1 $backupSource/$2 >> $backupDestination/backup_$date.log 2>> $backupDestination/backup_$date.log
	echo "\033[1;32mOK\033[0m\n"
}

copyFiles() {
	# backupSystem
	mkdir -p $backupSource/backupSystem
	mkdir -p $backupSource/backupSystem/backup
	mkdir -p $backupSource/backupSystem/backups

	paths=`readYaml .data.copy 0 | jq length-1`
	for index in `seq 0 $paths`
	do
		source=`readYaml ".data.copy[$index].source" 1`
		destination=`readYaml ".data.copy[$index].destination" 1 | sed "s|null||g"`
		copy $source $destination
	done

}

uploadToMEGA(){
	mega-put -q $backupDestination/*.tar.bz2 /
	mega-put -q $backupDestination/*.log /
	
}

backupCompress(){
        rm -rf $backupDestination/*

        print "compressing backup to $parent/backups/backup_$date.tar.bz2"
        tar -cvjSf $backupDestination/backup_$date.tar.bz2 $backupSource >> $backupDestination/backup_$date.log 2>> $parentDestination/backup_$date.log
        echo "\033[1;32mOK\033[0m\n"
}

main() {
	copyFiles
	backupCompress
	uploadToMEGA
}

main
