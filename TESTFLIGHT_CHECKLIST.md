# TestFlight Release Checklist

## ✅ Completed
- [x] CocoaPods issue fixed
- [x] Pod dependencies installed
- [x] iOS build started

## ✅ Build Complete
- [x] Flutter iOS build completed successfully (71.0MB)

## 📋 Next Steps (After Build Completes)

### 1. Open Xcode
```bash
open ios/Runner.xcworkspace
```

### 2. Configure Signing (in Xcode)
- [ ] Select "Runner" target
- [ ] Go to "Signing & Capabilities"
- [ ] Select your Team (Apple Developer account required)
- [ ] Bundle Identifier: `dk.dinnerhelp` (or your custom identifier)
- [ ] ✅ Automatically manage signing

### 3. Archive the App
- [ ] Select device: "Any iOS Device (arm64)"
- [ ] Menu: Product → Archive
- [ ] Wait for archive to complete (5-10 minutes)

### 4. Upload to App Store Connect
- [ ] In Organizer: Click "Distribute App"
- [ ] Choose "App Store Connect"
- [ ] Select "Upload"
- [ ] Complete validation
- [ ] Upload the build

### 5. Configure in App Store Connect
- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Create app if not exists
- [ ] Go to TestFlight tab
- [ ] Complete test information:
  - Beta App Description
  - Email
  - Demo account credentials (if needed)
- [ ] Add build to testing group

### 6. Important Settings to Verify

#### Bundle Identifier
Current: `dk.dinnerhelp` (from your project)
- Must match App Store Connect
- Must be registered in Apple Developer Portal

#### Version
Current: `1.0.0`
- Consider incrementing for each TestFlight build

#### Required Capabilities
- [x] Push Notifications (OneSignal configured)
- [x] Location Services
- [x] Background Modes

## 🚨 Common Issues

### "Team not found"
→ Add your Apple ID to Xcode: Preferences → Accounts

### "Bundle identifier not available"
→ Change to unique identifier like `com.yourcompany.dinnerhelp`

### "Provisioning profile doesn't include signing certificate"
→ Enable "Automatically manage signing" in Xcode

## 📱 Testing Recommendations

1. Test on real device before uploading
2. Start with internal testing (your team)
3. Fix critical issues
4. Then expand to external testers

## 🔑 Environment Variables

Make sure `.env` contains production values:
- SUPABASE_URL (production)
- SUPABASE_ANON_KEY (production)
- STRIPE_PUBLISHABLE_KEY (use test key for TestFlight)

---

Build completed at: 2025-08-20 07:00:22
Status: ✅ Build successful - 71.0MB