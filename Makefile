# Blast Radius. Targets match SPEC.md. GH_USER and TEAMMATE pass through to the scripts when set.
export GH_USER TEAMMATE

.PHONY: verify demo-local seed agent-dirs break break-device demo-message demo-message-device reset-demo

verify:
	python3 scripts/verify.py

demo-local:
	python3 scripts/verify.py --verbose

seed:
	scripts/seed.sh

agent-dirs:
	scripts/agent_dirs.sh

break:
	scripts/break.sh rename

break-device:
	scripts/break.sh device

demo-message:
	scripts/demo_message.sh

demo-message-device:
	scripts/demo_message.sh device

reset-demo:
	scripts/reset_demo.sh
