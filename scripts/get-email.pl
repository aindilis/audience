#!/bin/sh

fetchmail -a --fetchmailrc data/agent/email/fetchmailrc
/var/lib/myfrdcsa/sandbox/fetchyahoo-2.9.0/fetchyahoo-2.9.0/fetchyahoo --allmsgs --delete \
--username='<REDACTED>' --password=`cat data/agent/email/fetchyahoorc` --spoolfile='/var/mail/<REDACTED>'
