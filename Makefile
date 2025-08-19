.PHONY: build test lint format
build:
	xcodebuild -scheme JapaneseBuddy -destination 'platform=iOS Simulator,name=iPad Pro (11-inch)'
test:
	xcodebuild test -scheme JapaneseBuddy -destination 'platform=iOS Simulator,name=iPad Pro (11-inch)'
lint:
	swiftlint || true
format:
	swiftformat .
