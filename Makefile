.PHONY: build test lint format
build:
	xcodebuild -scheme JapaneseBuddy -destination 'generic/platform=iOS Simulator'
test:
	xcodebuild test -scheme JapaneseBuddy -destination 'generic/platform=iOS Simulator'
lint:
	swiftlint || true
format:
	swiftformat .
