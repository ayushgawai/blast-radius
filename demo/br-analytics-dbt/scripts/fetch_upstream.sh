#!/usr/bin/env bash
# Generate events.parquet from br-events-producer at UPSTREAM_REF and print its path.
# UPSTREAM_REF: env, else the first line of upstream.ref. Any branch, SHA or pull/<n>/head.
set -euo pipefail
cd "$(dirname "$0")/.."
UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/ayushgawai/br-events-producer.git}"
UPSTREAM_REF="${UPSTREAM_REF:-$(head -n1 upstream.ref)}"
rm -rf .upstream
git init -q .upstream
git -C .upstream fetch -q --depth 1 "$UPSTREAM_REPO" "$UPSTREAM_REF"
git -C .upstream checkout -q FETCH_HEAD
(cd .upstream && uv run --quiet python -m producer.generate --out data/events.parquet >/dev/null)
echo "$PWD/.upstream/data/events.parquet"
