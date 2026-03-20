#!/bin/bash
set -e

# Pre-publish check script for dart_desk packages.
# This temporarily modifies pubspecs for pub.dev compatibility,
# runs dry-run publish, then reverts changes.
#
# NOTE: Workspace root dependency_overrides (e.g., signals git fork)
# are intentional and NOT modified by this script. They don't affect
# individual package publishing.

PACKAGES=("packages/dart_desk_annotation" "packages/dart_desk_generator" "packages/dart_desk")

# Safety: restore all backups on any exit (success, failure, or signal)
trap 'for pkg in "${PACKAGES[@]}"; do [ -f "$pkg/pubspec.yaml.bak" ] && mv "$pkg/pubspec.yaml.bak" "$pkg/pubspec.yaml"; done' EXIT

for pkg in "${PACKAGES[@]}"; do
  echo "=== Checking $pkg ==="

  # Backup pubspec
  cp "$pkg/pubspec.yaml" "$pkg/pubspec.yaml.bak"

  # Remove resolution: workspace (not valid in published packages)
  sed -i '' '/^resolution: workspace$/d' "$pkg/pubspec.yaml"

  # Replace dart_desk_annotation path dep with version constraint (preserve indent)
  sed -i '' 's|^  dart_desk_annotation:$|  dart_desk_annotation: ^0.1.0|' "$pkg/pubspec.yaml"
  sed -i '' '/^    path: \.\.\/dart_desk_annotation$/d' "$pkg/pubspec.yaml"

  # Run dry-run
  echo "Running dart pub publish --dry-run for $pkg..."
  # --ignore-warnings: the "modified in git" warning is expected since we edit pubspec
  # NOTE: Packages must be published in order (annotation → generator → main).
  # The dry-run for generator/main will fail with "could not find package dart_desk_annotation"
  # until annotation is actually published. This is expected.
  if ! (cd "$pkg" && flutter pub get && dart pub publish --dry-run --ignore-warnings); then
    echo ""
    echo "FAILED: $pkg"
    echo "If the error is 'could not find package dart_desk_annotation', this is expected —"
    echo "publish dart_desk_annotation first, then re-run this script."
    exit 1
  fi

  # Restore pubspec (trap also handles this, but be explicit)
  mv "$pkg/pubspec.yaml.bak" "$pkg/pubspec.yaml"

  echo "=== $pkg OK ==="
  echo ""
done

echo "All packages passed dry-run checks!"
