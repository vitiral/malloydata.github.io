# MalloySQL

MalloySQL enables mixing dialect-specific SQL (including DDL) with Malloy. For example, MalloySQL can be used to create a new table in BigQuery, based on a model of existing data:

```malloy
>>>malloy
import "airports.malloy"

>>>sql connection:bigquery
CREATE TABLE major_airports AS ( // this is SQL
  SELECT name
  FROM %{
    airports -> major_airports  // this is a Malloy query
  }%
);
```

## Usage

MalloySQL can be used in the VSCode Extension and the Malloy CLI. In both cases, the extension of the file should be `.malloysql`.

MalloySQL files are composed of two kinds of statements - Malloy statements and SQL statements. Each statement is preceeded by a line that defines the statement type: `>>>malloy` or `>>>sql`. The SQL statement can also be passed a connection name - this is the name of the connection to use when executing the query. This is valid MalloySQL:

```malloy
>>>sql connection:duckdb
SELECT 1;
```

SQL statements can also contain embedded Malloy queries by wrapping the Malloy statement with `%{` and `}%`. To use embedded Malloy, a source must first be imported to use with the Malloy query:

```malloy
>>>malloy
import "mysource.malloy"

>>>sql connection:duckdb
SELECT name_count from %{ mysource -> names }%;
```

It is possible to use multiple SQL commands in one statement (although only the final result will be shown in the VSCode extension):

```malloy
>>>malloy
import "mysource.malloy"

>>>sql connection:duckdb
SELECT name_count from %{ mysource -> names }%;
SELECT airport_count from %{ mysource -> airports }%;
```

The first SQL statement must define a connection to be used for queries, but future SQL statements only need to define a connection if a different connection should be used. This is valid:

```malloy
>>>malloy
import "mysource.malloy"

>>>sql connection:duckdb
SELECT name_count from %{ mysource -> names }%;
>>>sql
SELECT airport_count from %{ mysource -> airports }%;
```

It is also possible to define connections in SQL using `--connection:{my_connection}`. This is useful when writing `.malloynb` files, as notebooks cannot obtain data from delimiter lines.

MalloySQL can contain multi (`/*...*/`) and single-line (`//` or `--`) comments.

Running a specific SQL statement in a Malloy file (by, for example, clicking the "Run" codelens in the VSCode extension) will execute all preceeding Malloy statements, but only the selected SQL statement.

## Example

Here is a more realistic example, using a Malloy model to wrangle raw data and create a useful parquet file with DuckDB:

```malloy
>>>malloy
import "raw_data.malloy"

>>>sql connection:duckdb

copy %{
  raw_titles -> {
    join_one: raw_ratings on tconst = raw_ratings.tconst
    join_one: raw_crew on tconst = raw_crew.tconst
    where: raw_ratings.numVotes > 30000
    project:
      tconst
      isAdult, originalTitle, primaryTitle
      startYear is startYear:::number
      endYear is endYear:::number
      runtimeMinutes is runtimeMinutes:::number
      genres is str_split!(genres,',')
      directors is str_split!(raw_crew.directors,',')
      writers is str_split!(raw_crew.writers,',')
      averageRating is raw_ratings.averageRating:::number
      numVotes is raw_ratings.numVotes:::number
    }
}%  to 'data/titles.parquet' (FORMAT 'parquet', CODEC 'ZSTD')
```
