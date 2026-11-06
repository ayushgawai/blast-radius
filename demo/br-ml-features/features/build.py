"""Per-user features for the churn model, built from events.parquet."""

import pandas as pd


def load_events(path) -> pd.DataFrame:
    return pd.read_parquet(path)


def event_type_counts(df: pd.DataFrame) -> pd.Series:
    return df["event_type"].value_counts()


def user_aggregates(df: pd.DataFrame) -> pd.DataFrame:
    return df.groupby("user_id").agg(
        events=("event_id", "count"),
        sessions=("session_id", "nunique"),
        revenue_usd=("revenue_usd", "sum"),
    )


def feature_matrix(df: pd.DataFrame) -> pd.DataFrame:
    by_type = df.pivot_table(index="user_id", columns="event_type", values="event_id", aggfunc="count", fill_value=0)
    return user_aggregates(df).join(by_type)
