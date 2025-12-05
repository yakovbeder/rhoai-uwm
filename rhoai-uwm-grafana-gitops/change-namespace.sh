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
GRAFANA_APP_DIR="overlays/grafana-uwm-user-app"

echo "Changing namespace from 'user-grafana' to '$NEW_NAMESPACE'..."

# Replace in application.yaml
sed -i '' "s/namespace: user-grafana/namespace: $NEW_NAMESPACE/g" application.yaml

# Replace in all YAML files in the main overlay directory
find "$OVERLAY_DIR" -type f -name "*.yaml" -exec sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in grafana-uwm-user-app overlay directory
find "$GRAFANA_APP_DIR" -type f -name "*.yaml" -exec sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in README.md files
find . -name "README.md" -type f -exec sed -i '' "s/user-grafana/$NEW_NAMESPACE/g" {} \;

echo "✓ Done! Namespace changed to '$NEW_NAMESPACE'"
echo ""
echo "Files modified:"
echo "  - application.yaml"
echo "  - $OVERLAY_DIR/namespace.yaml"
echo "  - $OVERLAY_DIR/kustomization.yaml"
echo "  - $OVERLAY_DIR/operator-group.yaml"
echo "  - $GRAFANA_APP_DIR/kustomization.yaml"
echo "  - $GRAFANA_APP_DIR/auth-delegator-binding.yaml"
echo "  - All other YAML files in overlay directories"
echo "  - README.md files"
echo ""
echo "Review changes with: git diff"

