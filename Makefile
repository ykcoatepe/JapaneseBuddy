.PHONY: build test build-device test-device lint format devices

# Xcode project configuration
PROJECT=JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj
SCHEME=JapaneseBuddyProj

# Simulator builds (default)
build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination 'generic/platform=iOS Simulator'

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination 'generic/platform=iOS Simulator'

# Physical device builds
# Usage:
#   make build-device UDID=<device-udid>
#   make test-device UDID=<device-udid>
# Find UDID: make devices
build-device:
	@if [ -z "$$UDID" ]; then \
		echo "Error: UDID not set. Run 'make devices' to list IDs, then 'make build-device UDID=<id>'"; \
		exit 1; \
	fi
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination "id=$$UDID" -configuration Debug -allowProvisioningUpdates build

test-device:
	@if [ -z "$$UDID" ]; then \
		echo "Error: UDID not set. Run 'make devices' to list IDs, then 'make test-device UDID=<id>'"; \
		exit 1; \
	fi
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination "id=$$UDID" -configuration Debug -allowProvisioningUpdates

# List available simulators and devices (requires Xcode command line tools)
devices:
	@./scripts/list_devices.sh || { echo "Install Xcode CLT and ensure 'xcrun' is available."; exit 1; }

lint:
	swiftlint || true

format:
	swiftformat .
