# desk_app developer commands.

.PHONY: goldens goldens-screens test test-integration

goldens: goldens-screens

goldens-screens:
	./scripts/regenerate-goldens.sh test/screens/

test:
	flutter test

test-integration:
	flutter test integration_test/
