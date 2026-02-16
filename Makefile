.PHONY: build test lint format

SIM_DEVICE ?=

build:
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination 'generic/platform=iOS Simulator' build
test:
	@sim_device=$(SIM_DEVICE); \
	if [ -z "$$sim_device" ]; then \
		sim_device=$$(xcrun simctl list devices available 2>/dev/null \
			| awk '/iPhone/ { name=$$0; sub(/^[[:space:]]+/, "", name); sub(/ \([0-9A-Fa-f-]{8}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{4}-[0-9A-Fa-f-]{12}\) \([^)]*\)[[:space:]]*$$/, "", name); print name; exit }'); \
	fi; \
	if [ -z "$$sim_device" ]; then \
		sim_device='iPhone 17 Pro'; \
	fi; \
	echo "▸ Using simulator: $$sim_device"; \
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination "platform=iOS Simulator,name=$$sim_device" test
lint:
	swiftlint || true
format:
	swiftformat .
