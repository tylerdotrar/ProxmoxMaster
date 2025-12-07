#!/bin/bash

# Simple script to check the health of the current Passbolt installation.
# (I can never remember the cake syntax)

# Author: Tyler McCann (tylerdotrar)
# Arbitrary Version Number: v1.0.0
# Link: https://github.com/tylerdotrar/ProxmoxMaster

su -s /bin/bash -c "source /etc/environment; cd /tmp; /usr/share/php/passbolt/bin/cake passbolt healthcheck" www-data
