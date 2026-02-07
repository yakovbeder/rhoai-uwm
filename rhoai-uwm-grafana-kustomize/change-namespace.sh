#!/usr/bin/env bash
set -euo pipefail

# Script to change namespace from 'user-grafana' to a new namespace
# This script only modifies overlay files, not the shared base resources.

# Check if namespace argument is provided
if [ -z "${1:-}" ]; then
  echo "Usage: $0 <new-namespace>"
  echo "Example: $0 yakov"
  exit 1
fi

readonly NEW_NAMESPACE="${1}"
readonly OVERLAY_DIR="overlays"

# Cross-platform sed in-place function
sed_in_place() {
  if [[ "${OSTYPE:-}" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

echo "Changing namespace from 'user-grafana' to '${NEW_NAMESPACE}'..."

# Replace in all YAML files in the overlay directory
if [ -d "${OVERLAY_DIR}" ]; then
  find "${OVERLAY_DIR}" -type f -name "*.yaml" -exec sed_in_place "s/user-grafana/${NEW_NAMESPACE}/g" {} \;
fi

# Replace in README.md
if [ -f "README.md" ]; then
  sed_in_place "s/user-grafana/${NEW_NAMESPACE}/g" README.md
fi

echo "Done! Namespace changed to '${NEW_NAMESPACE}'"
echo ""
echo "Files modified:"
echo "  - All YAML files in ${OVERLAY_DIR}/"
echo "  - README.md"
echo ""
echo "Note: Shared base resources in ../common/ are NOT modified."
echo "      Namespace transformation is handled by Kustomize overlays."
echo ""
echo "Review changes with: git diff"
