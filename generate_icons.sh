#!/bin/bash

echo "📱 Generating app icons for DinnerHelp..."

# Get dependencies
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons

echo "✅ App icons generated successfully!"
echo ""
echo "📝 Icons have been created for:"
echo "  • iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "  • Android: android/app/src/main/res/mipmap-*/"
echo ""
echo "🎨 Next steps:"
echo "  1. Make sure you've added your app_icon.png to assets/images/"
echo "  2. Run 'flutter clean' and 'flutter run' to see your new icon"