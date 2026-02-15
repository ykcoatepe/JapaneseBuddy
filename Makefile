.PHONY: build test lint format

# Pick first available iPhone simulator; override with: make test SIM_DEVICE="iPhone 17"
SIM_DEVICE ?= $(shell xcrun simctl list devices available 2>/dev/null | grep iPhone | head -1 | awk -F '[[:punct:]]' '{print $$1}' | xargs)

build:
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination 'generic/platform=iOS Simulator' build
test:
	@echo "▸ Using simulator: $(SIM_DEVICE)"
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination 'platform=iOS Simulator,name=$(SIM_DEVICE)' test
lint:
	swiftlint || true
format:
	swiftformat .
