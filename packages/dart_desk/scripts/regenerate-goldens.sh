#!/usr/bin/env bash
# Regenerate dart_desk goldens inside a Linux/arm64 Docker container so local
# pixels match CI pixels. CI runs on ubuntu-22.04-arm; macOS and x86 Linux
# render fonts/Skia slightly differently. Pinning --platform linux/arm64
# guarantees the same rasterization regardless of host arch.
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
# Mount one level above the dart_desk repo so sibling repos referenced via
# `../dart_desk_be/...` dependency_overrides remain visible inside Docker.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd "${PACKAGE_DIR}/../../.." && pwd)"
PACKAGE_REL="${PACKAGE_DIR#${WORKSPACE_ROOT}/}"

TARGET="${1:-test/}"

echo "→ Pulling ${IMAGE}"
docker pull --quiet "${IMAGE}"

# Find every host `.dart_tool` and `.flutter-plugins-dependencies` so we can
# shadow them inside the container with anonymous volumes. Without this,
# `flutter pub get` writes Linux/arm64 artifacts to the bind-mounted host
# tree, which clobbers the macOS Flutter SDK pointers and breaks `flutter
# run` until the host re-runs `flutter pub get`. Anonymous volumes are
# discarded when `--rm` cleans up the container, so the host stays pristine.
shadow_args=()
while IFS= read -r dir; do
  rel="${dir#${WORKSPACE_ROOT}/}"
  shadow_args+=(-v "/workspace/${rel}")
done < <(find "${WORKSPACE_ROOT}" -name .dart_tool -type d -prune 2>/dev/null)

echo "→ Running flutter test --update-goldens ${TARGET}"
echo "  (workspace: ${WORKSPACE_ROOT})"
echo "  (package:   ${PACKAGE_REL})"
echo "  (shadowing ${#shadow_args[@]} host paths from container writes)"

docker run --rm -t \
  --platform linux/arm64 \
  -v "${WORKSPACE_ROOT}:/workspace" \
  "${shadow_args[@]}" \
  -w "/workspace/${PACKAGE_REL}" \
  -e CI=1 \
  "${IMAGE}" \
  bash -c "flutter --suppress-analytics pub get && flutter test --update-goldens ${TARGET}"

echo "✓ Goldens regenerated. Review changes with 'git diff' and commit."
