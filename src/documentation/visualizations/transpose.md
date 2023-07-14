# Transposed Tables
For comparison, it is often interesting to turn a table on it's side.  The `# transpose` tag on a query does just that.

```malloy
--! {"isModel": true, "modelPath": "/inline/airports_mini.malloy"}
source: airports is duckdb.table('data/airports.parquet') {
    measure: airport_count is count()
}
```

## Normal Table

```malloy
--! {"isRunnable": true, "size":"medium", "isPaginationEnabled": true, "source": "/inline/airports_mini.malloy"}
run: airports -> {
  group_by: fac_type
  aggregate: 
    airport_count
    californa_count is airport_count {where: state='CA'}
    ny_count is airport_count {where: state='CA'}
    major_count is airport_count {where: major='Y'}
    average_elevation is elevation.avg()
}
```

## Transposed Table

Great for comparison

```malloy
--! {"isRunnable": true, "size":"medium", "isPaginationEnabled": true, "source": "/inline/airports_mini.malloy"}
# transpose
run: airports -> {
  group_by: fac_type
  aggregate: 
    airport_count
    californa_count is airport_count {where: state='CA'}
    ny_count is airport_count {where: state='CA'}
    major_count is airport_count {where: major='Y'}
    average_elevation is elevation.avg()
}
```