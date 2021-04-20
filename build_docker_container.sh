#!/usr/bin/env bash

docker pull mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Sq1ympics@" \
   -p 1433:1433 --name sql1 \
   -d mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04

docker ps
   
echo "
#Connect with ADS:
host: localhost
user: sa
password: Sq1ympics@
"
