#!/bin/bash

# Script to move files from one directory to another and reload apache

sudo mv /data/www/ittykeys/swiftsites.fyi/misc/swiftsites.fyi.conf /etc/apache2/sites-available/swiftsites.fyi.conf
./reloadapache.sh