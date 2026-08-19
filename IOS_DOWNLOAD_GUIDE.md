# 🍔 RestroHub iOS Download & Testing Guide

> [!IMPORTANT]
> This document provides instructions for testing RestroHub on iOS devices using cloud simulation services like **BrowserStack**. 
> Because this is an unsigned build, it cannot be installed directly on a real iPhone without developer signing.
> For Android users, please refer to the [APK Download Guide](APK_DOWNLOAD_GUIDE.md).

## 🎯 Quick Start

**⬇️ [Download Latest iOS IPA](https://github.com/milan-ghimire/RestroHub/releases/latest/download/RestroHub-iOS.ipa)**

This document provides complete instructions for downloading and testing the latest RestroHub
iOS build using BrowserStack.

---

## 📦 What You're Downloading

You are downloading **RestroHub** - a premium food delivery ecosystem built with:

- **Frontend**: Flutter/Dart (98%+)
- **AI Intelligence**: Google Gemini Integration
- **Backend**: Supabase (PostgreSQL, Realtime, Auth)
- **Local Database**: Drift (SQLite) with Atomic Sync

This iOS build is automatically created as an **Unsigned IPA** via GitHub Actions CI/CD pipeline, specifically optimized for cloud testing environments.

---

## ✅ System Requirements (BrowserStack)

Before testing, ensure you have:

| Requirement                     | Specification                                 |
|---------------------------------|-----------------------------------------------|
| **BrowserStack Account**        | Required (Free trial or paid)                 |
| **Storage Space**               | ~100MB for the IPA file                       |
| **Network**                     | Stable internet for cloud simulation          |
| **Device Selection**            | iPhone 13 or newer recommended for performance|

---

## 🚀 Testing Methods

### Method 1: BrowserStack Simulation (Recommended / No Mac Required)

Since RestroHub generates an unsigned `.ipa` artifact, you can test it using **BrowserStack App Live** even if you don't own a Mac or an iPhone.

#### Step 1: Download the IPA Asset
1. Go to the [RestroHub Latest Release](https://github.com/milan-ghimire/RestroHub/releases/latest) page.
2. Download the **RestroHub-iOS.ipa** asset.

#### Step 2: Upload to BrowserStack
1. Log in to your [BrowserStack App Live](https://www.browserstack.com/app-live) account.
2. Click on **"Upload"** in the "App" section.
3. Select the `RestroHub-iOS.ipa` file you just downloaded.
4. BrowserStack will automatically resign the app for testing on their real cloud devices.

#### Step 3: Select a Device & Launch
1. Choose an iPhone (e.g., iPhone 15 Pro) from the list.
2. BrowserStack will boot the device and install RestroHub.
3. Grant permissions (Location, Camera, Notifications) when prompted to test all features.

---

### Method 2: Direct Xcode Installation (For Developers with Mac)

If you have a Mac and a physical iPhone, you can build and run the app directly from source.

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
# - Go to "Signing & Capabilities" and select your Development Team
# - Connect your iPhone via USB
# - Select your device and press "Run" (Cmd+R)
```

---

## 🔒 Security & Permissions

RestroHub is built with security as a priority. Here's what the app accesses and why:

| Permission                 | Purpose                                                    |
|----------------------------|------------------------------------------------------------|
| **INTERNET**               | Connect to Supabase, Gemini AI, and track orders           |
| **LOCATION**               | Accurate delivery address and nearby restaurant discovery  |
| **CAMERA**                 | Capturing profile pictures and scanning features           |
| **NOTIFICATIONS**          | Real-time updates on food preparation and delivery         |

---

## 🐛 Troubleshooting

### Testing Issues

| Problem                                  | Solution                                                    |
|------------------------------------------|-------------------------------------------------------------|
| **"IPA failed to upload"**               | Ensure the file is named `RestroHub-iOS.ipa` and not corrupted. |
| **"Device session timed out"**           | Refresh your BrowserStack tab and restart the session.      |
| **"Location not detected"**              | Enable "GPS" or "Location Simulation" in BrowserStack menu. |
| **"App crashes on launch"**              | Check if the BrowserStack device OS is iOS 12.0 or higher.  |

### Runtime Issues

| Problem                              | Solution                                                                     |
|--------------------------------------|------------------------------------------------------------------------------|
| **"Permission denied" errors**       | Go to iOS Settings within the simulation -> RestroHub -> Grant permissions.  |
| **Network/sync issues**              | Ensure the simulated device has internet enabled in BrowserStack settings.   |
| **AI Assistant not responding**      | Verify that the `.env` keys were correctly set during the build process.    |

---

## 🔄 Updates

When new builds are released:

1. Download the new `RestroHub-iOS.ipa` from the releases page.
2. Re-upload it to BrowserStack.
3. Start a new session.

---

## 📊 Build Information

```
Build Type: Release (Unsigned)
Architecture: arm64
Min iOS: 12.0
Target iOS: 17.0+
Language Composition:
  - Dart (Flutter): 98.2%
  - Swift (iOS): 1.5%
  - Other: 0.3%
```

---

## 📞 Support & Feedback

### Report Bugs on GitHub

- Found a bug? [Open an issue on GitHub](https://github.com/milan-ghimire/RestroHub/issues)
- Include: Simulated device model, iOS version, and steps to reproduce.

### Request Features

- Have a feature idea? [Create a feature request](https://github.com/milan-ghimire/RestroHub/discussions)

---

## 🔐 Security Best Practices

1. **Secure Your API Keys** — Never commit your actual `.env` file to the repository.
2. **Use Strong Authentication** — Enable biometric simulation in BrowserStack if available.
3. **Be Cautious** — Only test IPAs downloaded from this official repository.

---

**Last Updated:** August 19, 2026  
**Repository:** [milan-ghimire/RestroHub](https://github.com/milan-ghimire/RestroHub)  
**License:** Apache License 2.0

---

<div align="center">

Built with ❤️ by **Milan Ghimire**

</div>
