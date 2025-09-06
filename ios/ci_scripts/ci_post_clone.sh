#!/bin/sh

# Fail this script if any subcommand fails.
set -e

echo "=== Starting CI post-clone script ==="
echo "Current directory: $(pwd)"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export FLUTTER_ROOT=$HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "Flutter installed at: $FLUTTER_ROOT"
flutter --version

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
echo "Precaching iOS artifacts..."
flutter precache --ios

# Install Flutter dependencies.
echo "Running flutter pub get..."
flutter pub get

# Fix FLUTTER_ROOT in Generated.xcconfig by replacing the existing line
echo "Updating FLUTTER_ROOT in Generated.xcconfig..."
if [ -f "ios/Flutter/Generated.xcconfig" ]; then
    # Use sed to replace the FLUTTER_ROOT line instead of appending
    sed -i '' "s|^FLUTTER_ROOT=.*|FLUTTER_ROOT=$HOME/flutter|" ios/Flutter/Generated.xcconfig
    echo "Updated FLUTTER_ROOT in Generated.xcconfig"
    echo "FLUTTER_ROOT is now:"
    grep "^FLUTTER_ROOT=" ios/Flutter/Generated.xcconfig
else
    echo "ERROR: Generated.xcconfig not found!"
    exit 1
fi

# Install CocoaPods using Homebrew.
echo "Installing CocoaPods..."
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
echo "Running pod install..."
cd ios && pod install # run `pod install` in the `ios` directory.

echo "=== CI post-clone script completed ==="
exit 0