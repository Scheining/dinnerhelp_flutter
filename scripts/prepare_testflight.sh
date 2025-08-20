#!/bin/bash

# DinnerHelp TestFlight Preparation Script
# This script prepares your Flutter app for TestFlight release

set -e

echo "🚀 DinnerHelp TestFlight Preparation Script"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check Flutter installation
echo -e "\n📱 Checking Flutter environment..."
if flutter doctor -v | grep -q "No issues found"; then
    print_success "Flutter environment is healthy"
else
    print_warning "Flutter has some issues. Run 'flutter doctor' for details"
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo -e "\n📌 Current version: $CURRENT_VERSION"

# Ask if user wants to update version
read -p "Do you want to update the version? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter new version (e.g., 1.0.1+2): " NEW_VERSION
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    print_success "Version updated to $NEW_VERSION"
fi

# Clean the project
echo -e "\n🧹 Cleaning project..."
flutter clean
print_success "Project cleaned"

# Get dependencies
echo -e "\n📦 Getting dependencies..."
flutter pub get
print_success "Dependencies updated"

# iOS specific setup
echo -e "\n🍎 Setting up iOS..."
cd ios

# Update pods
echo "Updating CocoaPods..."
pod deintegrate
pod cache clean --all
pod install --repo-update
print_success "CocoaPods updated"

cd ..

# Check for required environment variables
echo -e "\n🔑 Checking environment configuration..."
if [ -f ".env" ]; then
    print_success ".env file found"
    
    # Check for required keys
    REQUIRED_KEYS=("SUPABASE_URL" "SUPABASE_ANON_KEY")
    for key in "${REQUIRED_KEYS[@]}"; do
        if grep -q "^$key=" .env; then
            print_success "$key is configured"
        else
            print_error "$key is missing in .env"
        fi
    done
else
    print_error ".env file not found"
    echo "Creating .env template..."
    cat > .env.example << EOF
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
ONESIGNAL_APP_ID=your_onesignal_id
EOF
    print_warning "Created .env.example - please configure and rename to .env"
fi

# Build the iOS app
echo -e "\n🔨 Building iOS app..."
read -p "Do you want to build the iOS app now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flutter build ios --release --no-codesign
    print_success "iOS app built successfully"
    
    echo -e "\n📱 Next steps:"
    echo "1. Open Xcode: open ios/Runner.xcworkspace"
    echo "2. Select 'Any iOS Device (arm64)' as target"
    echo "3. Product → Archive"
    echo "4. Distribute App → App Store Connect → Upload"
    echo ""
    echo "📝 Don't forget to:"
    echo "   - Set your Team in Signing & Capabilities"
    echo "   - Verify Bundle Identifier matches App Store Connect"
    echo "   - Enable required capabilities (Push Notifications, etc.)"
else
    echo -e "\n📝 To build later, run:"
    echo "   flutter build ios --release --no-codesign"
fi

# Final checklist
echo -e "\n✅ Pre-flight Checklist:"
echo "[ ] Apple Developer account active"
echo "[ ] Bundle ID registered in Apple Developer Portal"
echo "[ ] Signing certificates configured"
echo "[ ] App icons present (1024x1024 for App Store)"
echo "[ ] Privacy descriptions in Info.plist"
echo "[ ] Test on physical device"
echo "[ ] TestFlight test information prepared"

echo -e "\n🎉 Preparation complete!"
echo "For detailed instructions, see: docs/TESTFLIGHT_RELEASE_GUIDE.md"

# Open Xcode if user wants
read -p "Open Xcode now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open ios/Runner.xcworkspace
fi