#!/bin/bash

# initial build including wwi backup files and restore script
docker build . --rm -t mssql-unittest:temp

# start a docker container to further build layers.
docker run --name unittestdb -e "ACCEPT_EULA=Y" -p 1433:1433 -d mssql-unittest:temp

# sql server needs 10 to 15 seconds to bootup
sleep 15

docker ps

echo 'Starting data sanitization'
cd ../../data_sanitization
powershell ./create_unittest_db.ps1

dt=`date '+%Y-%m-%d_%H-%M-%S'`

docker commit unittestdb sqlpass.azurecr.io/mssql-dev-db-image:$dt
docker tag sqlpass.azurecr.io/mssql-dev-db-image:$dt sqlpass.azurecr.io/mssql-dev-db-image:latest

docker push sqlpass.azurecr.io/mssql-dev-db-image:$dt
docker push sqlpass.azurecr.io/mssql-dev-db-image:latest

echo 'Finished build and publishing sanitized database image.'