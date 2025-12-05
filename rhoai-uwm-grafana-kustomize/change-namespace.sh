#!/bin/bash
# Script to change namespace from 'user-grafana' to a new namespace

# Check if namespace argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <new-namespace>"
    echo "Example: $0 yakov"
    exit 1
fi

NEW_NAMESPACE="$1"
OVERLAY_DIR="overlays/rhoai-uwm-user-grafana-app"

echo "Changing namespace from 'user-grafana' to '$NEW_NAMESPACE'..."

# Replace in all YAML files in the overlay directory
find "$OVERLAY_DIR" -type f -name "*.yaml" -exec sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in grafana-uwm-user-app overlay directory
find "overlays/grafana-uwm-user-app" -type f -name "*.yaml" -exec sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in README.md
sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" README.md

echo "✓ Done! Namespace changed to '$NEW_NAMESPACE'"
echo ""
echo "Files modified:"
echo "  - $OVERLAY_DIR/infrastructure-rbac/namespace.yaml"
echo "  - $OVERLAY_DIR/infrastructure-rbac/kustomization.yaml"
echo "  - $OVERLAY_DIR/infrastructure-rbac/operator-group.yaml"
echo "  - $OVERLAY_DIR/infrastructure-rbac/auth-delegator-binding.yaml"
echo "  - $OVERLAY_DIR/grafana-instance/kustomization.yaml"
echo "  - $OVERLAY_DIR/dashboards/kustomization.yaml"
echo "  - overlays/grafana-uwm-user-app/kustomization.yaml"
echo "  - README.md"
echo ""
echo "Review changes with: git diff"

