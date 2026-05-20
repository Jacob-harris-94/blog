#!/bin/bash

set -e  # exit on first error

WHEN="* * * * *"
CMD="cd $(realpath .) && ./job.sh &>> $(pwd)/job.log"

# below modified from:
# Source - https://stackoverflow.com/a/878647
# Posted by dogbane, modified by community. See post 'Timeline' for change history
# Retrieved 2026-05-19, License - CC BY-SA 3.0

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "${WHEN} ${CMD}" >> mycron
#install new cron file
crontab mycron
rm mycron

