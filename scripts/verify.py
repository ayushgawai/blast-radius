"""End to end check of the Blast Radius demo, fully local (no GitHub, no Switch).

1. Every downstream repo is green against upstream main.
2. On the rename branch, exactly the 6 breakages in SPEC.md appear.
3. After the fixes from SPEC.md, every repo is green against the rename branch.
4. On the add-device-type branch (no impact), every repo is green.

Exit 0 only when all four hold. --verbose prints each failing run's output.
"""

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEMO = ROOT / "demo"
IGNORE = shutil.ignore_patterns(".venv", ".upstream", ".reports", "target", "logs", "data", "__pycache__", ".pytest_cache")
VERBOSE = "--verbose" in sys.argv

EXPECTED = {
    "br-analytics-dbt": {"fct_sessions", "dim_users"},
    "br-ml-features": {"test_user_aggregates", "test_feature_matrix_shape"},
    "br-dashboards-sql": {"test_query[daily_active_users]", "test_query[revenue_by_user]"},
}
FIX_FILES = {
    "br-analytics-dbt": ["models/marts/fct_sessions.sql", "models/marts/dim_users.sql", "models/marts/schema.yml"],
    "br-ml-features": ["features/build.py"],
    "br-dashboards-sql": ["queries/daily_active_users.sql", "queries/revenue_by_user.sql"],
}


def git(cwd, *args):
    subprocess.run(["git", "-c", "user.name=verify", "-c", "user.email=verify@localhost", *args], cwd=cwd, check=True, capture_output=True)


def make_upstream(tmp: Path) -> Path:
    """A local git copy of br-events-producer with the two demo branches."""
    up = tmp / "br-events-producer"
    shutil.copytree(DEMO / "br-events-producer", up, ignore=IGNORE)
    schema = up / "producer" / "schema.py"
    original = schema.read_text()
    git(up, "init", "-q", "-b", "main")
    git(up, "add", "-A")
    git(up, "commit", "-qm", "init")
    for branch, edited in [
        ("rename-user-key", original.replace('USER_KEY = "user_id"', 'USER_KEY = "account_id"')),
        ("add-device-type", original.replace('    ("revenue_usd", "DOUBLE"),\n', '    ("revenue_usd", "DOUBLE"),\n    ("device_type", "VARCHAR"),\n')),
    ]:
        assert edited != original, f"could not make {branch}"
        git(up, "checkout", "-qb", branch, "main")
        schema.write_text(edited)
        git(up, "commit", "-qam", branch)
    git(up, "checkout", "-q", "main")
    return up


def failures(repo: Path) -> set[str]:
    """Names of failed dbt models or pytest cases from the last make test."""
    run_results = repo / "target" / "run_results.json"
    if run_results.exists():
        results = json.loads(run_results.read_text())["results"]
        return {r["unique_id"].split(".")[-1] for r in results if r["unique_id"].startswith("model.") and r["status"] == "error"}
    junit = repo / ".reports" / "junit.xml"
    if junit.exists():
        cases = ET.parse(junit).iter("testcase")
        return {c.get("name") for c in cases if c.find("failure") is not None or c.find("error") is not None}
    return {"<no results file>"}


def run(repo: Path, upstream: Path, ref: str) -> tuple[int, set[str]]:
    for stale in ("target/run_results.json", ".reports/junit.xml"):
        (repo / stale).unlink(missing_ok=True)
    env = {**os.environ, "UPSTREAM_REPO": str(upstream), "UPSTREAM_REF": ref}
    p = subprocess.run(["make", "test"], cwd=repo, env=env, capture_output=True, text=True)
    failed = failures(repo) if p.returncode else set()
    if VERBOSE and p.returncode:
        out = p.stdout + p.stderr
        print("\n".join(line for line in out.splitlines() if re.search(r"Error|FAILED|failed|ERROR", line)))
    return p.returncode, failed


def apply_fix(repo: Path, name: str):
    for rel in FIX_FILES[name]:
        f = repo / rel
        f.write_text(f.read_text().replace("user_id", "account_id"))
    (repo / "upstream.ref").write_text("rename-user-key\n")


def main() -> int:
    ok = True
    total_breakages = 0
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        upstream = make_upstream(tmp)
        print(f"{'repo':<20} {'main':<6} {'rename':<30} {'fixed':<6} {'no impact':<9}")
        for name, expected in EXPECTED.items():
            repo = tmp / name
            shutil.copytree(DEMO / name, repo, ignore=IGNORE)
            main_rc, _ = run(repo, upstream, "main")
            rename_rc, broke = run(repo, upstream, "rename-user-key")
            device_rc, _ = run(repo, upstream, "add-device-type")
            apply_fix(repo, name)
            fixed_rc, _ = run(repo, upstream, "rename-user-key")
            total_breakages += len(broke)
            row_ok = main_rc == 0 and rename_rc != 0 and broke == expected and fixed_rc == 0 and device_rc == 0
            ok &= row_ok
            status = lambda rc: "green" if rc == 0 else "RED"
            print(f"{name:<20} {status(main_rc):<6} {', '.join(sorted(broke)) or 'none':<30} {status(fixed_rc):<6} {status(device_rc):<9} {'ok' if row_ok else 'MISMATCH'}")
            if broke != expected:
                print(f"  expected to break: {sorted(expected)}")
    ok &= total_breakages == 6
    print(f"\n{total_breakages} breakages across {len(EXPECTED)} repos on the rename; expected 6.")
    print("VERIFY PASSED" if ok else "VERIFY FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
