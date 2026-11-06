"""Run every dashboard query against the latest events. A query passes if it returns rows."""

import os
from pathlib import Path

import duckdb
import pytest

QUERIES = sorted(Path(__file__).parent.parent.joinpath("queries").glob("*.sql"))


@pytest.fixture(scope="session")
def con():
    con = duckdb.connect()
    con.execute(f"CREATE VIEW events AS SELECT * FROM read_parquet('{os.environ['EVENTS_PATH']}')")
    return con


@pytest.mark.parametrize("query", QUERIES, ids=[q.stem for q in QUERIES])
def test_query(con, query):
    assert con.execute(query.read_text()).fetchall()
