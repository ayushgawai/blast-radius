# br-ml-features

Owner: Manav Patel (@Patel-manav20)

Per-user features for the churn model, built with pandas from the events table in [br-events-producer](https://github.com/ayushgawai/br-events-producer).

| Function | What |
| --- | --- |
| `user_aggregates` | events, sessions and revenue per user |
| `feature_matrix` | aggregates plus event counts by type, one row per user |

```
make test                               # pytest against upstream main
UPSTREAM_REF=rename-user-key make test  # against an upstream branch
```

The upstream ref comes from `UPSTREAM_REF`, else `upstream.ref`. Part of [Blast Radius](https://github.com/ayushgawai/blast-radius).
