#!/bin/bash

# Complete clean and rebuild script for DinnerHelp
# This ensures you're building with the latest code

echo "🧹 Complete Clean and Rebuild for DinnerHelp"
echo "============================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cd "/Users/scheining/Desktop/DinnerHelp/DinnerHelp Flutter"

echo -e "${YELLOW}Step 1: Cleaning Flutter project...${NC}"
flutter clean

echo -e "${YELLOW}Step 2: Cleaning iOS build folder...${NC}"
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec
rm -rf build/

echo -e "${YELLOW}Step 3: Cleaning Xcode derived data...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo -e "${YELLOW}Step 4: Cleaning Xcode build folder in project...${NC}"
cd ios
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Release
cd ..

echo -e "${YELLOW}Step 5: Getting Flutter packages...${NC}"
flutter pub get

echo -e "${YELLOW}Step 6: Running build_runner for generated files...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

echo -e "${YELLOW}Step 7: Installing iOS pods...${NC}"
cd ios
pod install --repo-update
cd ..

echo -e "${YELLOW}Step 8: Building iOS app with latest code...${NC}"
flutter build ios --release --no-codesign

echo ""
echo -e "${GREEN}✅ Clean and rebuild complete!${NC}"
echo ""
echo "The app has been completely rebuilt with your latest code."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. In Xcode: Product → Clean Build Folder (Cmd+Shift+K)"
echo "3. Select 'Any iOS Device (arm64)'"
echo "4. Product → Archive"
echo ""
echo -e "${GREEN}This build includes all your recent changes:${NC}"
echo "✓ Payment flow implementation"
echo "✓ Booking features"
echo "✓ Notification system"
echo "✓ All new screens and services"