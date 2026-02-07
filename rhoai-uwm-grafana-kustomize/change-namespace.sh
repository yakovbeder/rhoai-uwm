#!/usr/bin/env bash
set -euo pipefail

# Changes the Kustomize namespace across overlay files and README.
# Only modifies overlays and README — shared base resources are not touched.

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <new-namespace>"
  echo "Example: $0 yakov"
  exit 1
fi

readonly NEW_NS="${1}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${SCRIPT_DIR}"

sed_in_place() {
  if [[ "${OSTYPE:-}" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

CURRENT_NS=$(grep -m1 '^namespace:' overlays/rhoai-uwm-user-grafana-app/infrastructure-rbac/kustomization.yaml | awk '{print $2}')

if [ -z "${CURRENT_NS}" ]; then
  echo "Error: could not detect current namespace from overlay kustomization.yaml"
  exit 1
fi

if [ "${CURRENT_NS}" = "${NEW_NS}" ]; then
  echo "Namespace is already '${NEW_NS}'. Nothing to do."
  exit 0
fi

echo "Changing namespace: '${CURRENT_NS}' -> '${NEW_NS}'..."

while IFS= read -r -d '' file; do
  sed_in_place "s/${CURRENT_NS}/${NEW_NS}/g" "${file}"
done < <(find overlays -type f -name "*.yaml" -print0)

if [ -f "README.md" ]; then
  sed_in_place \
    -e "s/\`${CURRENT_NS}\`/\`${NEW_NS}\`/g" \
    -e "s/-n ${CURRENT_NS}/-n ${NEW_NS}/g" \
    -e "s/cluster-monitoring-view-${CURRENT_NS}/cluster-monitoring-view-${NEW_NS}/g" \
    -e "s/auth-delegator-${CURRENT_NS}/auth-delegator-${NEW_NS}/g" \
    README.md
fi

echo "Done. Review changes with: git diff"
