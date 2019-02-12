# iOneMySgMap

A tile server to serve map tiles for Singapore based off the
[Geofabrik OSM Data Extracts](http://download.geofabrik.de/index.html)

## Submodules

Remember to checkout the submodules: `git submodule update --init`

## Building the Tiles

The script `build.sh` will build the tiles in `./openmaptiles/data`.

## Serving the tiles

You can serve the tiles for [MapBox GL](https://github.com/mapbox/mapbox-gl-js) using
[`tileserver-gl`](https://github.com/klokantech/tileserver-gl).

The included `docker-compose.yml` will start a server and serve the Singapore tiles off `./tiles/singapore.mbtiles`.

It will also include pre-built styles from [another repository](https://github.com/Neo-Type/openmaptiles-styles).

```bash
docker-compose up
```

## Alternatives

- [`byom`](https://github.com/chrissng/byom)

## Credits

The build script is based off the quick start script from [OpenMapTiles](http://openmaptiles.org/).

Map data, and libraries are credited below:

- [© OpenMapTiles](http://openmaptiles.org/)
- [© Geofabrik GmbH](http://www.geofabrik.de/)
- [© OpenStreetMap contributors](http://www.openstreetmap.org/copyright)
