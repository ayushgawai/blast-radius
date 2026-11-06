# br-dashboards-sql

Owner: Ayush Gawai (@ayushgawai)

The SQL behind the product dashboards, one file per tile in `queries/`, run against the events table from [br-events-producer](https://github.com/ayushgawai/br-events-producer).

`tests/test_queries.py` runs every query in DuckDB; a query passes when it returns rows.

```
make test                               # all queries against upstream main
UPSTREAM_REF=rename-user-key make test  # against an upstream branch
```

The upstream ref comes from `UPSTREAM_REF`, else `upstream.ref`. Part of [Blast Radius](https://github.com/ayushgawai/blast-radius).
