#!/usr/bin/env bash
# Regenerate dart_desk goldens inside a Linux Docker container so local pixels
# match CI pixels. CI is pinned to Linux and macOS/Windows render fonts
# slightly differently; running --update-goldens on a Mac and committing the
# results produces a CI diff every time.
#
# Usage:
#   ./scripts/regenerate-goldens.sh                 # all goldens
#   ./scripts/regenerate-goldens.sh test/inputs/    # a subdirectory
#
# Requires Docker. Mounts the repository read-write so updated PNGs land in
# your working tree.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.6}"
IMAGE="ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}"

# Resolve to the package root (parent of this script's directory).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd "${PACKAGE_DIR}/../.." && pwd)"
PACKAGE_REL="${PACKAGE_DIR#${WORKSPACE_ROOT}/}"

TARGET="${1:-test/}"

echo "→ Pulling ${IMAGE}"
docker pull --quiet "${IMAGE}"

echo "→ Running flutter test --update-goldens ${TARGET}"
echo "  (workspace: ${WORKSPACE_ROOT})"
echo "  (package:   ${PACKAGE_REL})"

docker run --rm -t \
  -v "${WORKSPACE_ROOT}:/workspace" \
  -w "/workspace/${PACKAGE_REL}" \
  -e CI=1 \
  "${IMAGE}" \
  bash -c "flutter --suppress-analytics pub get && flutter test --update-goldens ${TARGET}"

echo "✓ Goldens regenerated. Review changes with 'git diff' and commit."
