#!/bin/bash

# Fix CocoaPods compatibility issue with Xcode 16

echo "🔧 Fixing CocoaPods compatibility issue..."
echo "========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}This script will fix the CocoaPods/Xcode 16 compatibility issue${NC}"
echo ""

# Method 1: Update CocoaPods
echo "📦 Method 1: Updating CocoaPods (requires admin password)..."
echo "Run this command manually:"
echo -e "${GREEN}sudo gem install cocoapods${NC}"
echo ""

# Method 2: Use Homebrew (if available)
echo "📦 Method 2: If you have Homebrew, run:"
echo -e "${GREEN}brew update && brew upgrade cocoapods${NC}"
echo ""

# Method 3: Temporary workaround - downgrade project format
echo "📦 Method 3: Temporary workaround (no admin required)..."
cd "/Users/scheining/Desktop/DinnerHelp/DinnerHelp Flutter/ios"

# Backup the project file
echo "Creating backup of project file..."
cp Runner.xcodeproj/project.pbxproj Runner.xcodeproj/project.pbxproj.backup

# Modify the project format version
echo "Modifying project format version..."
sed -i '' 's/objectVersion = 70/objectVersion = 60/g' Runner.xcodeproj/project.pbxproj
sed -i '' 's/compatibilityVersion = "Xcode 16.0"/compatibilityVersion = "Xcode 14.0"/g' Runner.xcodeproj/project.pbxproj

echo -e "${GREEN}✓ Project format temporarily downgraded${NC}"

# Try to run pod install again
echo ""
echo "Attempting pod install with workaround..."
pod install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Pod installation successful!${NC}"
else
    echo "Pod installation still failed. Trying alternative approach..."
    
    # Alternative: Remove Pods and try fresh install
    echo "Cleaning Pods completely..."
    rm -rf Pods
    rm -rf Podfile.lock
    rm -rf ~/Library/Caches/CocoaPods
    
    echo "Attempting fresh pod install..."
    pod install --repo-update
fi

cd ..

echo ""
echo "🎯 Next steps:"
echo "1. If pods installed successfully, continue with TestFlight preparation"
echo "2. If still failing, update CocoaPods manually with:"
echo "   sudo gem install cocoapods"
echo "3. Or install via Homebrew:"
echo "   brew install cocoapods"
echo ""
echo "After updating CocoaPods, run:"
echo "   cd ios && pod install && cd .."