# Rendering Numbers

Malloy's render provides a variety of ways to render numeric values.  Tagging a number will change how the number is displayed in the result set but the underlying value doesn't change.

The following examples that follow use the Malloy semantic data model below.

```malloy
--! {"isModel": true, "modelPath": "/inline/e.malloy"}
source: airports is duckdb.table('data/airports.parquet') {
  dimension: name is concat(code, ' - ', full_name)
  measure: airport_count is count()
}

source: flights is duckdb.table('data/flights.parquet') {
  join_one: orig is airports on origin=orig.code
  join_one: dest is airports on destination = dest.code

  measure: 
    flight_count is count()

}

```

## # percent
Carriers as percentage of flights

```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "small", "pageSize": 100000 }
run: flights -> {
  group_by: carrier
  # percent
  aggregate: percent_of_flights is flight_count/all(flight_count)
}
```

## # value_format

Malloy uses LookMLs (Excel) string definitions for formatting numbers.

```
# format="0"             # Integer (123)
# format="*00#"          # Integer zero-padded to 3 places (001)
# format="0 \" String\"" # Integer followed by a string (123 String)
                              #   Note \"String\" can be replaced with any other word

# format="0.##"          # Number up to 2 decimals (1. or 1.2 or 1.23)
# format="0.00"          # Number with exactly 2 decimals (1.23)
# format="*00#.00"       # Number zero-padded to 3 places and exactly 2 decimals (001.23)
# format="#,##0"         # Number with comma between thousands (1,234)
# format="#,##0.00"      # Number with comma between thousands and 2 decimals (1,234.00)
# format="0.000,,\" M\"" # Number in millions with 3 decimals (1.234 M)
                              #   Note division by 1 million happens automatically
# format="0.000,\" K\""  # Number in thousands with 3 decimals (1.234 K)
                              #   Note division by 1 thousand happens automatically

# format="$0"            # Dollars with 0 decimals ($123)
# format="$0.00"         # Dollars with 2 decimals ($123.00)
# format="\"€\"0"        # Euros with 0 decimals (€123)
# format="$#,##0.00"     # Dollars with comma btwn thousands and 2 decimals ($1,234.00)
# format="$#.00;($#.00)" # Dollars with 2 decimals, positive values displayed
                              #   normally, negative values wrapped in parenthesis

# format="0\%"           # Display as percent with 0 decimals (1 becomes 1%)
# format="0.00\%"        # Display as percent with 2 decimals (1 becomes 1.00%)
# format="0%"            # Convert to percent with 0 decimals (.01 becomes 1%)
# format="0.00%"         # Convert to percent with 2 decimals (.01 becomes 1.00%)
```

```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "small", "pageSize": 100000 }
run: flights -> {
  // tag a single element
  aggregate:
    # value_format="0"
    `integer` is flight_count

  // tag multiple elements at once.
  # value_format="$#,##0;($#,##0)"
  aggregate:
    dollars is flight_count
    neg_dollars is 0-flight_count
}
```

# # duration
Displaying a duration in human adusted scale can make data more readable.


```malloy
--! {"isRunnable": true, "source": "/inline/e.malloy", "size": "small", "pageSize": 100000 }
run: flights -> {
  group_by: dep_date is dep_time.day
  # duration="minutes"
  aggregate: 
    longest_flight_time is max(flight_time)
    total_flight_time is flight_time.sum()
  aggregate:
    flight_count    
  limit: 100
}
```