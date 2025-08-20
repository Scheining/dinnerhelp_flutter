# OneSignal iOS Setup Guide for DinnerHelp

This guide walks you through the iOS-specific setup for OneSignal push notifications. These steps must be completed manually in Xcode.

## Prerequisites

✅ OneSignal Flutter package has been added to `pubspec.yaml`
✅ OneSignal has been initialized in `main.dart`
✅ You have your OneSignal App ID ready from the OneSignal dashboard

## Step 1: Replace OneSignal App ID

1. Open `lib/main.dart`
2. Replace `"YOUR_APP_ID"` on line 31 with your actual OneSignal App ID
3. You can find your App ID in OneSignal Dashboard → Settings → Keys & IDs

## Step 2: iOS Configuration in Xcode

### 2.1 Open Project in Xcode
1. Navigate to `ios/` folder
2. Open `Runner.xcworkspace` (NOT Runner.xcodeproj)

### 2.2 Add Push Notifications Capability
1. Select the `Runner` target in Xcode
2. Go to "Signing & Capabilities" tab
3. Click the "+" button to add capability
4. Search for and add **Push Notifications**

### 2.3 Add Background Modes Capability
1. Still in "Signing & Capabilities" tab
2. Click "+" again to add another capability
3. Search for and add **Background Modes**
4. Check the **Remote notifications** checkbox

### 2.4 Configure App Groups
1. Still in "Signing & Capabilities" tab
2. Click "+" to add **App Groups** capability
3. Click the "+" button in the App Groups section
4. Create a new container ID using format: `group.YOUR_BUNDLE_ID.onesignal`
   - Example: If your bundle ID is `com.dinnerhelp.app`, use `group.com.dinnerhelp.app.onesignal`
5. **Important**: Keep the exact format `group.[bundle_id].onesignal`

## Step 3: Add Notification Service Extension

### 3.1 Create the Extension
1. In Xcode: **File** → **New** → **Target**
2. Select **Notification Service Extension**, then **Next**
3. Set Product Name to: `OneSignalNotificationServiceExtension`
4. Press **Finish**
5. When prompted "Activate scheme?", click **Cancel** (Don't Activate)

### 3.2 Configure NSE Target
1. Select the `OneSignalNotificationServiceExtension` target
2. Set the **Minimum Deployment Target** to match your main app (iOS 15+ recommended)
3. Go to "Signing & Capabilities" tab
4. Add **App Groups** capability
5. Add the SAME group ID you created in Step 2.4

### 3.3 Update NSE Code
1. Navigate to the `OneSignalNotificationServiceExtension` folder in Xcode
2. Open `NotificationService.swift`
3. Replace ALL content with this code:

```swift
import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    // Note this extension only runs when `mutable_content` is set
    // Setting an attachment or action buttons automatically sets the property to true
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // DEBUGGING: Uncomment the 2 lines below to check this extension is executing
//            print("Running NotificationServiceExtension")
//            bestAttemptContent.body = "[Modified] " + bestAttemptContent.body

            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
```

## Step 4: Update Podfile

The Podfile needs to be updated to include OneSignal for the Notification Service Extension.

1. Open `ios/Podfile` in a text editor
2. Add this target configuration at the end of the file (before the final `end`):

```ruby
target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end
```

3. Save the file

## Step 5: Install Pods

Run these commands in your terminal:

```bash
cd ios
pod install
cd ..
```

## Step 6: Build and Test

1. Clean and rebuild your project:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

2. Test on a physical iOS device (push notifications don't work in simulator)

## Troubleshooting

### Common Issues:

**Error: "Cycle Inside..." during build**
- This is usually a warning and can be ignored, but if it causes build failures, try cleaning the project and rebuilding.

**NSE shows errors until pods are installed**
- This is normal - the errors will disappear after running `pod install`

**Push notifications not working**
- Ensure you're testing on a physical device
- Check that your OneSignal App ID is correct
- Verify all capabilities are added correctly
- Make sure the App Group IDs match exactly

**App Group naming**
- The App Group must follow the exact format: `group.[your-bundle-id].onesignal`
- Both the main app and NSE must use the same App Group ID
- Capitalization and spelling must match your bundle ID exactly

## Next Steps

After completing the iOS setup:

1. Test push notifications using OneSignal's test feature
2. Configure your OneSignal dashboard with your iOS credentials (p8 token or p12 certificate)
3. Send test notifications to verify everything is working
4. Consider implementing user identification and tagging in your Flutter app

## Important Notes

- Always test on physical iOS devices (not simulator)
- Push notifications require proper Apple Developer Program enrollment
- Make sure your OneSignal app is configured with valid iOS credentials
- The verbose logging in `main.dart` should be removed in production builds

## Production Checklist

Before releasing to the App Store:

- [ ] Remove `OneSignal.Debug.setLogLevel(OSLogLevel.verbose);` from main.dart
- [ ] Test push notifications on multiple devices
- [ ] Verify notification service extension is working (rich notifications with images)
- [ ] Test confirmed delivery analytics
- [ ] Ensure proper App Store Connect configuration