# 🍔 RestroHub APK Download & Installation Guide

> [!IMPORTANT]
> This document has been consolidated into the main [README.md](README.md#installation). Please
> refer to the README for the most up-to-date installation instructions and build artifacts.

## 🎯 Quick Start

**⬇️ [Download APK from Build Artifacts](https://github.com/milan-ghimire/RestroHub/actions)**

This document provides complete instructions for downloading and installing the latest RestroHub
APK build.

---

## 📦 What You're Downloading

You are downloading **RestroHub** - a premium food delivery ecosystem built with:

- **Frontend**: Flutter/Dart (98%+)
- **AI Intelligence**: Google Gemini Integration
- **Backend**: Supabase (PostgreSQL, Realtime, Auth)
- **Local Database**: Drift (SQLite) with Atomic Sync

This APK is automatically built and packaged from the latest source code via GitHub Actions CI/CD
pipeline.

---

## ✅ System Requirements

Before installation, ensure your device meets these requirements:

| Requirement                     | Specification                                 |
|---------------------------------|-----------------------------------------------|
| **Minimum Android Version**     | Android 5.0 (API Level 21)                    |
| **Recommended Android Version** | Android 10.0 or higher                        |
| **Storage Space**               | At least 150MB free                           |
| **RAM**                         | Minimum 2GB (4GB+ recommended)                |
| **Network**                     | Internet connection required for AI & Orders  |

---

## 🚀 Installation Methods

### Method 1: Direct Installation (Easiest)

1. **Download the APK**
    - Click the download link above to get the APK file from the latest successful GitHub Action run.
    - Wait for download to complete.

2. **Prepare Your Device**
    - Go to: **Settings → Security** (or **Settings → Apps & notifications → Special app access**)
    - Find and toggle on **"Install unknown apps"** for your browser or file manager.
    - (This allows installation from outside Google Play Store)

3. **Install the Application**
    - Open your file manager.
    - Navigate to the **Downloads** folder.
    - Tap on the `restro_hub.apk` file.
    - Confirm installation when prompted.
    - Wait for installation to complete.

4. **Launch RestroHub**
    - Find the app in your app drawer.
    - Tap to open for the first time.
    - Grant all requested permissions:
        - ✓ Internet access
        - ✓ Location (for delivery address)
        - ✓ Camera (for profile photos & scanning)
        - ✓ Notifications (for order updates)

### Method 2: Command Line Installation (ADB)

For developers with Android SDK tools installed:

```bash
# Step 1: Connect your Android device via USB
# Enable USB Debugging on device: Settings → Developer Options → USB Debugging
adb devices

# Step 2: Install the APK
adb install path/to/restro_hub.apk

# Step 3: Launch the app
adb shell am start -n com.portfolio.restrohub/.MainActivity
```

### Method 3: Sideload via Android Studio

1. Open Android Studio.
2. Go to: **Tools → Device Manager**.
3. Select your emulator/device.
4. Drag and drop the downloaded `restro_hub.apk` onto the device screen.
5. Wait for installation to complete.

---

## 🔒 Security & Permissions

RestroHub is built with security as a priority. Here's what the app accesses and why:

| Permission                 | Purpose                                                    |
|----------------------------|------------------------------------------------------------|
| **INTERNET**               | Connect to Supabase, Gemini AI, and track orders           |
| **ACCESS_FINE_LOCATION**   | Accurate delivery address and nearby restaurant discovery  |
| **CAMERA**                 | Capturing profile pictures and future QR features          |
| **POST_NOTIFICATIONS**     | Real-time updates on your food preparation and delivery    |
| **READ_CONTACTS**          | Suggest saved contacts for sharing favorite restaurants    |
| **EXTERNAL_STORAGE**       | Cached images and app logs for troubleshooting            |

---

## 🐛 Troubleshooting

### Installation Issues

| Problem                                            | Solution                                        |
|----------------------------------------------------|-------------------------------------------------|
| **"Installation blocked" message**                 | Enable "Install unknown apps" in Settings       |
| **"Insufficient storage space"**                   | Free up at least 200MB and retry                |
| **"Installation failed" or APK corrupted**         | Re-download the APK file (may be incomplete)    |
| **"App not installed as package appears invalid"** | Ensure you downloaded the correct architecture  |

### Runtime Issues

| Problem                        | Solution                                                                     |
|--------------------------------|------------------------------------------------------------------------------|
| **App crashes on startup**     | Clear app cache: Settings → Apps → Restro Hub → Storage → Clear Cache        |
| **"Permission denied" errors** | Go to Settings → Apps → Restro Hub → Permissions → Grant missing permissions |
| **Network/sync issues**        | Check internet connection and ensure Supabase is accessible                  |
| **Slow performance**           | Close background apps or restart device                                      |

---

## 🔄 Updating

When new builds are released:

1. Download the new APK using the link above.
2. Install it over the existing version.
3. Your data and settings will be preserved by the Android system.
4. App will restart and show new features.

---

## 📊 Build Information

```
Build Type: Release / Debug
Architecture: arm64-v8a, armeabi-v7a, x86, x86_64
Min SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)
Language Composition:
  - Dart (Flutter): 98.2%
  - Kotlin (Android): 1.5%
  - Other: 0.3%
```

---

## 📞 Support & Feedback

### Report Issues

- Found a bug? [Open an issue on GitHub](https://github.com/milan-ghimire/RestroHub/issues)
- Include: Device model, Android version, and steps to reproduce.

### Request Features

- Have an idea? [Create a feature request](https://github.com/milan-ghimire/RestroHub/discussions)

---

## 🔐 Security Best Practices

1. **Keep Your Device Updated** - Install all Android security patches.
2. **Use Strong Authentication** - Enable biometrics within the app when prompted.
3. **Be Cautious** - Don't install from untrusted third-party sites outside this repository.

---

**Last Updated:** August 19, 2026  
**Repository:** [milan-ghimire/RestroHub](https://github.com/milan-ghimire/RestroHub)  
**License:** Apache License 2.0
