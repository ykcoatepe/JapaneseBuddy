.PHONY: build test lint format
build:
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination 'generic/platform=iOS Simulator' build
test:
	xcodebuild -project JapaneseBuddyProj/JapaneseBuddyProj.xcodeproj -scheme JapaneseBuddyProj -destination 'generic/platform=iOS Simulator' test
lint:
	swiftlint || true
format:
	swiftformat .
