#!/usr/bin/env bash
# Regenerate dart_desk goldens inside a Linux/arm64 Docker container so local
# pixels match CI pixels. CI runs on ubuntu-22.04-arm; macOS and x86 Linux
# render fonts/Skia slightly differently. Pinning --platform linux/arm64
# guarantees the same rasterization regardless of host arch.
#
# Usage:
#   ./scripts/regenerate-goldens.sh                          # all goldens
#   ./scripts/regenerate-goldens.sh test/inputs/             # subdirectory
#   ./scripts/regenerate-goldens.sh test/inputs/foo_test.dart  # single file
#
#   GOLDENS_RESET=1 ./scripts/regenerate-goldens.sh   # nuke long-lived container + caches
#
# Speed model:
#   1. A long-lived container `dartdesk-goldens` is reused across runs; we
#      `docker exec` into it. Container start overhead happens once.
#   2. Named volumes persist `.dart_tool` (one per workspace package) and
#      `/root/.pub-cache` between runs, so `flutter pub get` is fast and
#      packages aren't re-downloaded.
#   3. Named volumes also shadow host `.dart_tool` dirs so the container's
#      Linux/arm64 artifacts never leak into the macOS host tree.
#   4. `flutter test --no-pub` skips the redundant implicit pub get.
#   5. `flutter test -j` runs at host CPU concurrency.
#   6. The image is only pulled if it's not already present locally.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.6}"
IMAGE="ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION}"
CONTAINER_NAME="dartdesk-goldens"
PUB_CACHE_VOLUME="dartdesk-pub-cache"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_ROOT="$(cd "${PACKAGE_DIR}/../../.." && pwd)"
PACKAGE_REL="${PACKAGE_DIR#${WORKSPACE_ROOT}/}"

TARGET="${1:-test/}"

if [[ "${GOLDENS_RESET:-0}" == "1" ]]; then
  echo "→ GOLDENS_RESET=1: removing container + caches"
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  docker volume ls -q | grep -E "^(${PUB_CACHE_VOLUME}|dartdesk-darttool-)" \
    | xargs -r docker volume rm >/dev/null 2>&1 || true
fi

# Pull only if the image isn't already present (avoids registry round-trip).
if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "→ Pulling ${IMAGE}"
  docker pull --quiet "${IMAGE}"
fi

# Build named-volume mounts for every host `.dart_tool` so:
#  - the host tree never receives Linux/arm64 artifacts (no clobbering of
#    macOS Flutter SDK pointers / `flutter run` breakage), and
#  - the container's `.dart_tool` survives between runs (fast pub get).
volume_args=()
while IFS= read -r dir; do
  rel="${dir#${WORKSPACE_ROOT}/}"
  vol_name="dartdesk-darttool-$(echo "${rel}" | tr -c 'a-zA-Z0-9_.-' '-')"
  volume_args+=(-v "${vol_name}:/workspace/${rel}")
done < <(find "${WORKSPACE_ROOT}" -name .dart_tool -type d -prune 2>/dev/null)

# Reuse a long-lived container if it's already running. Otherwise start one.
if ! docker ps -q -f "name=^${CONTAINER_NAME}$" | grep -q .; then
  # Clean up a stopped container with the same name, if any.
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

  echo "→ Starting persistent container ${CONTAINER_NAME}"
  echo "  (workspace: ${WORKSPACE_ROOT})"
  echo "  (package:   ${PACKAGE_REL})"
  echo "  (shadowing ${#volume_args[@]} .dart_tool dirs with named volumes)"

  docker run -d \
    --name "${CONTAINER_NAME}" \
    --platform linux/arm64 \
    -v "${WORKSPACE_ROOT}:/workspace" \
    -v "${PUB_CACHE_VOLUME}:/root/.pub-cache" \
    "${volume_args[@]}" \
    -w "/workspace/${PACKAGE_REL}" \
    -e CI=1 \
    "${IMAGE}" \
    sleep infinity >/dev/null
else
  echo "→ Reusing running container ${CONTAINER_NAME}"
fi

JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"

echo "→ flutter pub get && flutter test --update-goldens --no-pub -j ${JOBS} ${TARGET}"
docker exec -t "${CONTAINER_NAME}" bash -c "
  set -euo pipefail
  flutter --suppress-analytics pub get
  flutter test --update-goldens --no-pub -j ${JOBS} ${TARGET}
"

echo "✓ Goldens regenerated. Review with 'git diff' and commit."
echo "  (container ${CONTAINER_NAME} left running for next time;"
echo "   GOLDENS_RESET=1 to wipe it and the caches)"
