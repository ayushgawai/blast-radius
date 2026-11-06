.PHONY: test
test:
	EVENTS_PATH=$$(./scripts/fetch_upstream.sh) && export EVENTS_PATH && uv run dbt build --profiles-dir . --project-dir .
