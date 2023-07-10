# Computing Moving Averages
Malloy can compute moving averages on result sets.   

The queries below use the following model

```malloy
--! {"isModel": true, "modelPath": "/inline/e1.malloy"}
source: order_items is table('duckdb:data/order_items.parquet') + {
  measure: 
    user_count is count(distinct user_id)
    order_count is count()
}
```
## Simple Moving average.

```malloy
--! {"isRunnable": true, "isPaginationEnabled": true, "size": "medium", "source": "/inline/e1.malloy", "pageSize":5000}
run: order_items -> {
  group_by: order_month is created_at.month
  aggregate: 
    order_count
  calculate: moving_avg_order_count is avg_moving(order_count, 3)
  order_by: order_month
}
```

## In Charts.

```malloy
--! {"isRunnable": true, "isPaginationEnabled": true, "size": "large", "source": "/inline/e1.malloy", "pageSize":5000}
run: order_items -> {
  # line_chart
  nest: non_averaged is {
    group_by: order_month is created_at.month
    aggregate: 
      order_count
    order_by: order_month
  }
  # line_chart
   nest: moving_averaged is {
    group_by: order_month is created_at.month
    calculate: moving_avg_order_count is avg_moving(order_count, 3)
    order_by: order_month
  }
}
```