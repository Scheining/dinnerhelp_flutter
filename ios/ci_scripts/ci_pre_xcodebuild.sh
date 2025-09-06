#!/bin/sh

# Fail this script if any subcommand fails.
set -e

echo "=== CI pre-xcodebuild script starting ==="
echo "Current directory: $(pwd)"

# Set Flutter environment
export FLUTTER_ROOT=$HOME/flutter
echo "FLUTTER_ROOT set to: $FLUTTER_ROOT"

# Verify Flutter exists
if [ ! -d "$FLUTTER_ROOT" ]; then
    echo "ERROR: Flutter not found at $FLUTTER_ROOT"
    echo "Contents of $HOME:"
    ls -la $HOME/
    exit 1
fi

# Verify xcode_backend.sh exists
XCODE_BACKEND="$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
if [ ! -f "$XCODE_BACKEND" ]; then
    echo "ERROR: xcode_backend.sh not found at $XCODE_BACKEND"
    echo "Contents of flutter_tools/bin:"
    ls -la "$FLUTTER_ROOT/packages/flutter_tools/bin/" 2>/dev/null || echo "Directory not found"
    exit 1
fi

echo "xcode_backend.sh found at: $XCODE_BACKEND"

# Verify Generated.xcconfig has correct FLUTTER_ROOT
GENERATED_XCCONFIG="$CI_PRIMARY_REPOSITORY_PATH/ios/Flutter/Generated.xcconfig"
if [ -f "$GENERATED_XCCONFIG" ]; then
    echo "Generated.xcconfig contents (first 20 lines):"
    head -20 "$GENERATED_XCCONFIG"
    echo ""
    echo "FLUTTER_ROOT from Generated.xcconfig:"
    grep "^FLUTTER_ROOT=" "$GENERATED_XCCONFIG"
else
    echo "WARNING: Generated.xcconfig not found at $GENERATED_XCCONFIG"
fi

echo "=== CI pre-xcodebuild script completed ==="
exit 0