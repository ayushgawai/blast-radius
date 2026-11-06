# br-analytics-dbt

Owner: Manav Patel (@Patel-manav20)

dbt models on top of the events table from [br-events-producer](https://github.com/ayushgawai/br-events-producer).

| Model | What |
| --- | --- |
| `stg_events` | the raw events |
| `fct_sessions` | one row per session |
| `dim_users` | one row per user |

```
make test                               # dbt build against upstream main
UPSTREAM_REF=rename-user-key make test  # against an upstream branch
```

The upstream ref comes from `UPSTREAM_REF`, else `upstream.ref`. Part of [Blast Radius](https://github.com/ayushgawai/blast-radius).
