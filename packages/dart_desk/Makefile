# dart_desk developer commands.

.PHONY: goldens goldens-inputs goldens-screens test test-integration

goldens:
	./scripts/regenerate-goldens.sh

goldens-inputs:
	./scripts/regenerate-goldens.sh test/inputs/

goldens-screens:
	./scripts/regenerate-goldens.sh test/screens/

test:
	flutter test

test-integration:
	flutter test integration_test/
