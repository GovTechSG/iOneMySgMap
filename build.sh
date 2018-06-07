#!/usr/bin/env bash
set -xeuo pipefail

cd openmaptiles
mkdir -p data

echo "====> : Downloading Singapore Metro Extract"
curl https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf -o data/singapore.osm.pbf

cp ../.env .env
cp ../docker-compose-config.yml data/docker-compose-config.yml

./quickstart.sh singapore
