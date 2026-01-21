#!/bin/bash
# Script to change namespace from 'user-grafana' to a new namespace

# Check if namespace argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <new-namespace>"
    echo "Example: $0 yakov"
    exit 1
fi

NEW_NAMESPACE="$1"
OVERLAY_DIR="overlays"
COMMON_DIR="../common"

# Determine sed command based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_IN_PLACE="sed -i ''"
else
    SED_IN_PLACE="sed -i"
fi

echo "Changing namespace from 'user-grafana' to '$NEW_NAMESPACE'..."

# Replace in all YAML files in the overlay directory
find "$OVERLAY_DIR" -type f -name "*.yaml" -exec $SED_IN_PLACE "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in common base files
find "$COMMON_DIR" -type f -name "*.yaml" -exec $SED_IN_PLACE "s/user-grafana/$NEW_NAMESPACE/g" {} \;

# Replace in README.md
$SED_IN_PLACE "s/user-grafana/$NEW_NAMESPACE/g" README.md

echo "Done! Namespace changed to '$NEW_NAMESPACE'"
echo ""
echo "Files modified:"
echo "  - All YAML files in $OVERLAY_DIR/"
echo "  - All YAML files in $COMMON_DIR/"
echo "  - README.md"
echo ""
echo "Review changes with: git diff"
