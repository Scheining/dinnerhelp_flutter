# TestFlight Release Guide for DinnerHelp

## Prerequisites

### 1. Apple Developer Account
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] Access to App Store Connect
- [ ] Team ID and signing certificates configured

### 2. Required Tools
- [ ] Xcode (latest version)
- [ ] Flutter SDK (latest stable)
- [ ] CocoaPods installed
- [ ] Valid provisioning profiles

## Step-by-Step Release Process

### Step 1: Update Version Numbers

Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: version+build_number
# Example: 1.0.0+1 for first TestFlight release
# Increment build number for each upload: 1.0.0+2, 1.0.0+3, etc.
```

### Step 2: Configure iOS Settings

1. Open project in Xcode:
```bash
cd ios
open Runner.xcworkspace
```

2. In Xcode, select Runner target and update:
   - **Bundle Identifier**: `com.dinnerhelp.app` (or your registered identifier)
   - **Team**: Select your development team
   - **Signing**: Enable "Automatically manage signing"
   - **Deployment Target**: iOS 12.0 or higher

### Step 3: App Icons and Assets

Ensure app icons are configured:
```bash
# Generate app icons if needed
flutter pub run flutter_launcher_icons
```

Required icon sizes for iOS:
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 152x152 (iPad @2x)
- 76x76 (iPad @1x)

### Step 4: Configure Capabilities

In Xcode, under "Signing & Capabilities":
- [ ] Push Notifications (if using OneSignal)
- [ ] Background Modes (already configured)
- [ ] Associated Domains (if using deep links)

### Step 5: Update Info.plist

Add/verify these entries in `ios/Runner/Info.plist`:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

<key>NSCameraUsageDescription</key>
<string>DinnerHelp needs camera access to upload chef profile photos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>DinnerHelp needs photo library access to select images</string>

<key>NSContactsUsageDescription</key>
<string>DinnerHelp uses contacts to help you invite friends</string>
```

### Step 6: Clean and Build

```bash
# Clean everything
flutter clean
cd ios
pod deintegrate
pod cache clean --all
cd ..

# Reinstall dependencies
flutter pub get
cd ios
pod install
cd ..

# Build for release
flutter build ios --release --no-codesign
```

### Step 7: Archive in Xcode

1. Open Xcode:
```bash
open ios/Runner.xcworkspace
```

2. Select target device: "Any iOS Device (arm64)"

3. Product → Archive
   - This creates an archive for distribution
   - Wait for the build to complete (5-10 minutes)

### Step 8: Upload to App Store Connect

1. In Xcode Organizer (Window → Organizer):
   - Select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Choose options:
     - [ ] Include bitcode for iOS content
     - [x] Upload your app's symbols
   - Click "Next" through validation
   - Click "Upload"

### Step 9: Configure TestFlight

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)

2. Select your app

3. Go to TestFlight tab

4. Complete Test Information:
   - **Beta App Description**: What to test
   - **Beta App Review Information**:
     - Contact email
     - Phone number
     - Demo account (if needed)
   - **License Agreement**: Standard Apple EULA

5. Add Build to Testing:
   - Wait for processing (15-30 minutes)
   - Add to Internal Testing Group first
   - Test internally
   - Add to External Testing Groups

### Step 10: Invite Testers

#### Internal Testing (up to 100 testers)
- Add Apple IDs directly
- Immediate access

#### External Testing (up to 10,000 testers)
1. Create testing group
2. Add tester emails or share public link
3. Submit for Beta Review (24-48 hours)
4. Testers receive invitation

## Environment Configuration

### Create .env files for different environments:

**.env.production**
```env
SUPABASE_URL=https://your-prod-url.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key
STRIPE_PUBLISHABLE_KEY=pk_live_...
ONESIGNAL_APP_ID=your-onesignal-id
```

**.env.staging**
```env
SUPABASE_URL=https://your-staging-url.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key
STRIPE_PUBLISHABLE_KEY=pk_test_...
ONESIGNAL_APP_ID=your-test-onesignal-id
```

## Common Issues and Solutions

### Issue: "No valid code signing identity found"
**Solution**: 
- Check Apple Developer account status
- Download certificates from Apple Developer portal
- In Xcode: Preferences → Accounts → Download Manual Profiles

### Issue: "The app identifier cannot be registered"
**Solution**:
- Ensure bundle ID is unique
- Register it in Apple Developer portal first

### Issue: "Missing Push Notification Entitlement"
**Solution**:
- Enable Push Notifications in Capabilities
- Regenerate provisioning profiles

### Issue: Build fails with pod errors
**Solution**:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
flutter clean
flutter build ios
```

## Pre-Submission Checklist

### Functionality
- [ ] All core features working
- [ ] Payment flow tested with Stripe test cards
- [ ] Push notifications working
- [ ] Deep links functioning
- [ ] Offline mode handling

### Performance
- [ ] App launches in < 3 seconds
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Images optimized

### Security
- [ ] API keys not hardcoded
- [ ] Sensitive data encrypted
- [ ] SSL pinning implemented
- [ ] Input validation working

### Legal
- [ ] Privacy Policy URL updated
- [ ] Terms of Service URL updated
- [ ] GDPR compliance
- [ ] Age restrictions set

### Testing
- [ ] Tested on iPhone SE (smallest)
- [ ] Tested on iPhone 15 Pro Max (largest)
- [ ] Tested on iPad
- [ ] iOS 12+ compatibility verified

## TestFlight Beta Testing Tips

1. **Start with Internal Testing**
   - Test with team members first
   - Fix critical issues before external testing

2. **Prepare Test Plan**
   - List specific features to test
   - Provide test credentials
   - Include feedback instructions

3. **Monitor Crashes**
   - Check Xcode Organizer for crash reports
   - Use TestFlight crash reporting
   - Implement analytics (Firebase/Sentry)

4. **Iterate Quickly**
   - Fix bugs and upload new builds
   - Builds expire after 90 days
   - Keep testers engaged with updates

## Build Commands Reference

```bash
# Development build
flutter run --debug

# Release build for testing
flutter run --release

# Build IPA without code signing
flutter build ios --release --no-codesign

# Build with specific flavor
flutter build ios --release --flavor staging

# Clean build
flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter build ios
```

## Next Steps After TestFlight

1. **Collect Feedback**
   - Use TestFlight feedback
   - Implement crash reporting
   - Track user analytics

2. **Prepare for App Store**
   - App Store screenshots (6.5", 5.5", iPad)
   - App preview video (optional)
   - App description and keywords
   - App Store review guidelines compliance

3. **Submit for Review**
   - Usually takes 24-48 hours
   - Respond quickly to reviewer feedback
   - Have a rollback plan

## Important URLs

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Portal](https://developer.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Support

For issues specific to DinnerHelp:
- Technical: [your-email]
- TestFlight: [testflight-support-email]

---

Last Updated: [Current Date]
Version: 1.0.0