#!/usr/bin/env bash
set -xeuo pipefail

cd openmaptiles

mkdir -p build
mkdir -p data

echo "====> : Pulling or refreshing OpenMapTiles docker images "
make refresh-docker-images

echo "====> : Stopping running services & removing old containers"
make clean-docker

echo "====> : Downloading Singapore Metro Extract"
curl https://s3.amazonaws.com/metro-extracts.mapzen.com/singapore.osm.pbf -o data/singapore.osm.pbf

echo "====> : Remove old generated source files ( ./build/* ) ( if they exist ) "
docker run --userns=host --rm -v $(pwd):/tileset openmaptiles/openmaptiles-tools make clean

echo "-------------------------------------------------------------------------------------"
echo "====> : Code generating from the layer definitions ( ./build/mapping.yaml; ./build/tileset.sql )"
echo "      : The tool source code: https://github.com/openmaptiles/openmaptiles-tools "
echo "      : But we generate the tm2source, Imposm mappings and SQL functions from the layer definitions! "
docker run --userns=host --rm -v $(pwd):/tileset openmaptiles/openmaptiles-tools make

echo "-------------------------------------------------------------------------------------"
echo "====> : Start PostgreSQL service ; create PostgreSQL data volume "
docker-compose up   -d postgres

echo "-------------------------------------------------------------------------------------"
echo "====> : Drop and Recreate PostgreSQL  public schema "
make forced-clean-sql

echo "-------------------------------------------------------------------------------------"
echo "====> : Start importing water data from http://openstreetmapdata.com into PostgreSQL "
docker-compose run --rm import-water

echo "-------------------------------------------------------------------------------------"
echo "====> : Start importing border data from http://openstreetmap.org into PostgreSQL "
docker-compose run --rm import-osmborder

echo "-------------------------------------------------------------------------------------"
echo "====> : Start importing  http://www.naturalearthdata.com  into PostgreSQL "
docker-compose run --rm import-natural-earth

echo "-------------------------------------------------------------------------------------"
echo "====> : Start importing OpenStreetMap Lakelines data "
docker-compose run --rm import-lakelines

echo "-------------------------------------------------------------------------------------"
echo "====> : Start importing OpenStreetMap data: ./data -> imposm3[./build/mapping.yaml] -> PostgreSQL"
docker-compose run --rm import-osm

echo "-------------------------------------------------------------------------------------"
echo "====> : Start SQL postprocessing:  ./build/tileset.sql -> PostgreSQL "
echo "      : Source code: https://github.com/openmaptiles/import-sql "
docker-compose run --rm import-sql

echo "-------------------------------------------------------------------------------------"
echo "====> : Analyze PostgreSQL tables"
make psql-analyze

echo "-------------------------------------------------------------------------------------"
echo "====> : Start generating MBTiles (containing gzipped MVT PBF) from a TM2Source project. "
docker-compose run --rm \
  -e BBOX="103.062, 0.807, 104.545, 1.823" \
  -e MIN_ZOOM="0" \
  -e MAX_ZOOM="18" \
  -e OSM_AREA_NAME="Singapore Metro Area" \
  generate-vectortiles

echo "-------------------------------------------------------------------------------------"
echo "====> : Add special metadata to mbtiles! "
docker-compose run --rm openmaptiles-tools  generate-metadata ./data/tiles.mbtiles
docker-compose run --rm openmaptiles-tools  chmod 666         ./data/tiles.mbtiles

echo "-------------------------------------------------------------------------------------"
echo "====> : Stop PostgreSQL service ( but we keep PostgreSQL data volume for debugging )"
docker-compose stop postgres
