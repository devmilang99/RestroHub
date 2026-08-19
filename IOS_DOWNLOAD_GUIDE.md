# 🍔 RestroHub iOS Download & Installation Guide

> [!IMPORTANT]
> This document provides instructions for downloading and installing RestroHub on iOS devices via TestFlight.
> For Android users, please refer to the [APK Download Guide](APK_DOWNLOAD_GUIDE.md).

## 🎯 Quick Start

**⬇️ [Download via TestFlight](https://testflight.apple.com/join/YOUR_PUBLIC_LINK)**

This document provides complete instructions for downloading and installing the latest RestroHub
iOS build via Apple TestFlight.

---

## 📦 What You're Downloading

You are downloading **RestroHub** - a premium food delivery ecosystem built with:

- **Frontend**: Flutter/Dart (98%+)
- **AI Intelligence**: Google Gemini Integration
- **Backend**: Supabase (PostgreSQL, Realtime, Auth)
- **Local Database**: Drift (SQLite) with Atomic Sync

This iOS build is automatically created and distributed via TestFlight from the latest source code via 
GitHub Actions CI/CD pipeline.

---

## ✅ System Requirements

Before installation, ensure your device meets these requirements:

| Requirement                     | Specification                                 |
|---------------------------------|-----------------------------------------------|
| **Minimum iOS Version**         | iOS 12.0 or higher                            |
| **Recommended iOS Version**     | iOS 15.0 or higher                            |
| **Storage Space**               | At least 200MB free                           |
| **RAM**                         | 2GB minimum (3GB+ recommended)                |
| **Network**                     | Internet connection required for AI & Orders  |
| **Apple ID**                    | Required for TestFlight access                |

---

## 🚀 Installation & Testing Methods

### Method 1: TestFlight Installation (Recommended for Real Devices)

TestFlight is Apple's official beta testing platform. Installing via TestFlight is the easiest way to get the
latest RestroHub build on your iOS device.

#### Step 1: Install TestFlight

1. Open the **App Store** on your iPhone or iPad
2. Search for **"TestFlight"**
3. Tap **Get** and then **Install**
4. Sign in with your Apple ID if prompted

Or use this direct link: [TestFlight on App Store](https://apps.apple.com/app/testflight/id899247664)

#### Step 2: Join the RestroHub Beta

**Option A: Via Email Invitation (If you received an email)**

1. Check your email inbox for the TestFlight invitation from Apple
2. Open the email on your iOS device
3. Tap the **"View in TestFlight"** link
4. You'll be taken directly to the RestroHub TestFlight page
5. Tap **"Install"** to add the app to your device

**Option B: Via Public Invitation Link**

1. Open this link on your iOS device: **[TestFlight Public Link](https://testflight.apple.com/join/YOUR_PUBLIC_LINK)**
2. You'll be redirected to the TestFlight app (or App Store if TestFlight isn't installed)
3. Review the app details and tap **"Install"**
4. Follow any prompts to confirm installation

#### Step 3: Install the Application

1. Once you tap Install, TestFlight will begin downloading and installing RestroHub
2. Wait for the installation to complete (progress indicator will show)
3. Once installed, the "Install" button will change to "Open"
4. Tap **"Open"** to launch RestroHub for the first time

#### Step 4: Grant Permissions

When you launch RestroHub for the first time, grant all requested permissions:

- ✓ **Internet Access** — Connect to Supabase, Gemini AI, and order services
- ✓ **Location (Always or While Using)** — For delivery address and nearby restaurant discovery
- ✓ **Camera** — For profile photos and future QR code scanning features
- ✓ **Notifications** — For real-time order updates on food preparation and delivery
- ✓ **Contacts** (optional) — To suggest saved contacts when sharing favorite restaurants
- ✓ **Photo Library** (optional) — For uploading profile pictures

---

### Method 2: BrowserStack Simulation (No Mac Required)

Since RestroHub is built on GitHub Actions, you can download the generated `.ipa` artifact and test it using services like **BrowserStack** even if you don't own a Mac.

#### Step 1: Download the IPA Artifact
1. Go to the [RestroHub Latest Release](https://github.com/milan-ghimire/RestroHub/releases/latest) page.
2. Download the **RestroHub-iOS.ipa** asset.
3. Once downloaded, you are ready to upload it to BrowserStack.

#### Step 2: Upload to BrowserStack App Live
1. Log in to your [BrowserStack App Live](https://www.browserstack.com/app-live) account.
2. Click on **"Upload"** in the "App" section.
3. Select the `RestroHub-iOS.ipa` file you just downloaded.
4. BrowserStack will automatically resign the app for testing on their real devices.

#### Step 3: Select a Device & Launch
1. Choose an iPhone (e.g., iPhone 15 Pro) from the list.
2. BrowserStack will boot the device and install RestroHub.
3. Grant permissions (Location, Camera, Notifications) when prompted to test all features.

> [!TIP]
> This method is perfect for verifying UI layouts and basic functionality on various iOS versions without needing local Apple hardware.

---

### Method 3: Direct Xcode Installation (For Developers with Mac)

For developers with Xcode installed on macOS:

```bash
# Step 1: Clone the repository
git clone https://github.com/milan-ghimire/RestroHub.git
cd RestroHub

# Step 2: Install Flutter dependencies
flutter pub get

# Step 3: Run code generation
dart run build_runner build --delete-conflicting-outputs

# Step 4: Open iOS project in Xcode
open ios/Runner.xcworkspace

# Step 5: In Xcode
# - Select "Runner" project in left sidebar
# - Select "Runner" target
# - Go to "Signing & Capabilities"
# - Select your development team
# - Connect your iOS device via USB
# - Select your device in the top toolbar
# - Press Cmd+R or click "Run" button
```

### Method 4: Command Line Installation (For Developers with Mac)

```bash
# Step 1: Navigate to project directory
cd RestroHub

# Step 2: Install dependencies
flutter pub get

# Step 3: Run on your connected iOS device
flutter run -v
```

---

## 🔒 Security & Permissions

RestroHub is built with security as a priority. Here's what the app accesses and why:

| Permission                 | Purpose                                                    |
|----------------------------|------------------------------------------------------------|
| **INTERNET**               | Connect to Supabase, Gemini AI, and track orders           |
| **LOCATION_ALWAYS**        | Accurate delivery address and nearby restaurant discovery  |
| **LOCATION_WHEN_IN_USE**   | Temporary location access during checkout and delivery     |
| **CAMERA**                 | Capturing profile pictures and future QR scanning features |
| **USER_NOTIF**             | Real-time updates on food preparation and delivery         |
| **CONTACTS** (optional)    | Suggest saved contacts for sharing favorite restaurants    |
| **PHOTO_LIBRARY** (optional)| Uploading custom profile pictures                         |

---

## 🐛 Troubleshooting

### Installation Issues

| Problem                                  | Solution                                                    |
|------------------------------------------|-------------------------------------------------------------|
| **"Cannot connect to TestFlight"**       | Check your internet connection and Apple ID credentials     |
| **"App cannot be installed at this time"** | Wait a few minutes and try again; TestFlight servers may be busy |
| **"Insufficient storage"**               | Free up at least 250MB on your device and retry             |
| **"Expired TestFlight link"**            | Contact us to request a new invitation (links expire after 28 days) |
| **"Beta offer has expired"**             | The testing period has ended; check for a public App Store release |

### Runtime Issues

| Problem                              | Solution                                                                     |
|--------------------------------------|------------------------------------------------------------------------------|
| **App crashes on startup**           | Force close and reopen; if persists, delete and reinstall via TestFlight    |
| **"Permission denied" errors**       | Go to Settings → RestroHub → Permissions → Toggle the necessary permissions |
| **App appears outdated**             | Check TestFlight for a newer build; update via TestFlight when available    |
| **Network/sync issues**              | Check internet connection; ensure Supabase services are accessible          |
| **Slow performance**                 | Close background apps or restart your device                                |
| **"Untrusted Developer" message**    | Go to Settings → General → Device Management → Trust the developer          |

---

## 🔄 Updates & New Builds

When new builds are released:

1. Open the **TestFlight** app
2. Navigate to **RestroHub**
3. If an update is available, tap **"Update"** (or wait for auto-update if enabled)
4. Your data and settings will be preserved
5. App will launch with new features

**Enable Automatic Updates:**

1. Open TestFlight app
2. Go to **Account** → **Settings**
3. Toggle **"Automatic Updates"** on
4. RestroHub will update automatically when new builds are available

---

## 📊 Build Information

```
Build Type: Release
Architecture: arm64 (native), arm64e (enhanced)
Min iOS: 12.0
Target iOS: 17.0+
Language Composition:
  - Dart (Flutter): 97.3%
  - Swift (iOS): 2.3%
  - Other: 0.4%

TestFlight Build Status: ✅ Active
```

---

## ⏰ TestFlight Build Expiration

**Important:** TestFlight beta builds automatically expire **90 days** after they are made available.
If your installed build expires:

1. You'll receive a notification
2. Update via TestFlight when the new build is available
3. Your app data will be preserved during the update

---

## 📞 Support & Feedback

### Send Feedback via TestFlight

The easiest way to report issues or send feedback:

1. Open the **TestFlight** app
2. Select **RestroHub**
3. Tap **"Send Beta Feedback"**
4. Describe your feedback or bug
5. Include screenshots if applicable
6. Tap **Send**

### Report Bugs on GitHub

- Found a critical bug? [Open an issue on GitHub](https://github.com/milan-ghimire/RestroHub/issues)
- Include: Device model, iOS version, build number, and steps to reproduce
- Check the build information in Settings → About RestroHub for version details

### Request Features

- Have a feature idea? [Create a feature request](https://github.com/milan-ghimire/RestroHub/discussions)

---

## 🔐 Security Best Practices

1. **Keep Your Device Updated** — Install all iOS security updates from Apple
2. **Use Strong Authentication** — Enable Face ID / Touch ID when prompted by the app
3. **Secure Your Apple ID** — Use a strong password and enable two-factor authentication
4. **Trust Developer Only When Necessary** — Only trust developers when installing beta apps
5. **Be Cautious** — Only install from official TestFlight links provided by us

---

## ❓ FAQ

**Q: Is TestFlight safe?**  
A: Yes. TestFlight is Apple's official beta testing platform and all builds are scanned for security.

**Q: Will my data be saved if the beta expires?**  
A: Yes. Your app data is stored locally and in Supabase. Updating or reinstalling preserves your data.

**Q: Can I use RestroHub on multiple iOS devices?**  
A: Yes. Use the same Apple ID on each device and accept the TestFlight invitation on each device.

**Q: How do I remove RestroHub?**  
A: Open TestFlight, select RestroHub, tap **"Remove This App"** or delete it from your home screen.

**Q: What if I want the App Store version instead?**  
A: RestroHub may be available on the App Store. Search for "RestroHub" in the App Store app.

---

## 📋 Feedback Template

When reporting issues, please include:

```
Device Model: iPhone 14 Pro
iOS Version: 17.2
Build Number: [Check in Settings → About RestroHub]
Issue: [Describe what happened]
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
Expected Behavior: [What should happen]
Actual Behavior: [What actually happened]
Screenshots: [Attach if applicable]
```

---

**Last Updated:** August 19, 2026  
**Repository:** [milan-ghimire/RestroHub](https://github.com/milan-ghimire/RestroHub)  
**License:** Apache License 2.0

---

<div align="center">

Built with ❤️ by **Milan Ghimire**

</div>
