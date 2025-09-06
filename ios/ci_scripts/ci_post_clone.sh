#!/bin/sh

# This script is executed by Xcode Cloud after cloning the repository
# It ensures all dependencies are properly installed before building

echo "Starting post-clone setup..."

# Navigate to iOS directory
cd ios

# Install CocoaPods if not already installed
if ! command -v pod &> /dev/null; then
    echo "Installing CocoaPods..."
    sudo gem install cocoapods
fi

# Clean previous pod installations
echo "Cleaning previous Pod installations..."
rm -rf Pods
rm -f Podfile.lock

# Install pods
echo "Installing CocoaPods dependencies..."
pod install --repo-update

# Ensure Flutter is properly configured
echo "Configuring Flutter..."
cd ..
flutter pub get
flutter precache --ios

# Return to iOS directory
cd ios

echo "Post-clone setup completed successfully!"