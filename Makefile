.PHONY: get format analyze test

get:
	flutter pub get

format:
	dart format lib test

analyze:
	flutter analyze

test:
	flutter test