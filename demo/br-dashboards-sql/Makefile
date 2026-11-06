.PHONY: test
test:
	EVENTS_PATH=$$(./scripts/fetch_upstream.sh) && export EVENTS_PATH && uv run pytest -v --tb=line --junitxml=.reports/junit.xml
