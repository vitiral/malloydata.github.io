 # Rendering Results

When Malloy runs a query, it returns two things.  The *results* of the query and *metadata* about the results.  The metadata are the schema for the results, including type information.  Malloy also provides a mechanism to tag things in the source code and return tags with this meta data. 

In Malloy, anything that can be named can be tagged.  A tag start with a `#`.  Tags that start on a new line attach the tag the thing on the following line.

Malloy's rendering library can read these tags and to change how results are rendered.

## Tagging individual elements
In the query below, the measure **percent_of_total** is tagged as a percentage.  Anytime *percent_of_total* is used in a query, Malloy's rendering library will be displayed as a percentage.

```malloy
--! {"isRunnable": true, "isPaginationEnabled": true, "size": "small", "pageSize":5000}
source: flights is duckdb.table('data/flights.parquet') {
  measure:
    flight_count is count()
    # percent
    percent_of_flights is flight_count/all(flight_count)
}

run: flights ->  {
  group_by: carrier
  aggregate: 
    flight_count 
    percent_of_flights
}
```

```malloy
--! {"isRunnable": true, "isPaginationEnabled": true, "size": "small", "pageSize":5000}
run: duckdb.table('data/flights.parquet') ->  {
  group_by: carrier
  aggregate: flight_count is count()
}
```

Simply adding `# bar_chart` before the query tags it and tells the rendering library to show the result as a bar chart.

```malloy
--! {"isRunnable": true, "isPaginationEnabled": true, "size": "large", "pageSize":5000}
# bar_chart
run: duckdb.table('data/flights.parquet') ->  {
  group_by: carrier
  aggregate: flight_count is count()
}
```

Malloy's renderering library uses the [Vega-Lite](https://vega.github.io/vega-lite/) for charting, allowing visualization of results. Malloy's rendering library is a separate layer from Malloy's data access layer.:

## Rendering tags

* [Number](numbers.md) - number formatting, percentages, duration, and bytes
* [Transposed Tables](transpose.md)
* [Dashboards](dashboards.md) 
* [Lists](lists.md)
* [Bar Charts](bar_charts.md) - various forms of column charts 
* [Line Charts](charts_line_chart.md) 
* [Scatter Charts](scatter_charts.md)
* [Shape Maps](shape_maps.md)
* [Segment Maps](segment_maps.md)


## Additional Charting with Vega Lite
The `vega` renderer allows much more customization of rendering than the default visualization options provided in the Extension, using the [Vega-Lite](https://vega.github.io/vega-lite/) library. For examples of using these in Malloy, check out the `flights_custom_vis` model and styles files in the FAA [Sample Models](../samples.md) download.