# Segment Maps

The plugin currently supports US maps. Segment maps take as input 4 columns: start latitude , start longitude, end latitude, and  end longitude of the segment.  The model and data styles for the subsequent examples are:

```malloy
--! {"isModel": true, "modelPath": "/inline/e.malloy"}
source: airports is duckdb.table('data/airports.parquet') {
  dimension: name is concat(code, ' - ', full_name)
  measure: airport_count is count()
}

source: flights is duckdb.table('data/flights.parquet') {
  join_one: orig is airports on origin=orig.code
  join_one: dest is airports on destination = dest.code

  measure: flight_count is count()

  # segment_map
  query: routes_map is {
    group_by:
      orig.latitude
      orig.longitude
      latitude2 is dest.latitude
      longitude2 is dest.longitude
    aggregate: flight_count
  }
}

```

## Run as a simple query
Departing from Chicago

```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "medium", "pageSize": 100000 }
run: flights { where: dep_time = @2003-02 and origin = 'ORD' } -> routes_map
```

## Run as a trellis
By calling the configured map as a nested query, a trellis is formed.

```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "medium"}
run: flights { where: dep_time = @2003-02 and origin = 'ORD' } -> {
  group_by: carrier
  aggregate: flight_count
  nest: routes_map
}
```

## Run as a trellis, repeated with different filters

```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "medium", "pageSize": 100000 }
run: flights -> {
  group_by: carrier
  aggregate: flight_count
  nest:
    ord_segment_map is routes_map { where: origin = 'ORD' }
    sfo_segment_map is routes_map { where: origin = 'SFO' }
    jfk_segment_map is routes_map { where: origin = 'JFK' }
}

```