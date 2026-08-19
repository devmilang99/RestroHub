# 🔧 GitHub Actions & App Store Connect Setup Guide

> This guide walks you through setting up iOS build artifacts and TestFlight deployment for RestroHub.

---

## 📋 Overview

The updated CI/CD workflow automatically builds and deploys iOS apps to TestFlight. This requires:

1. **App Store Connect Account** (Apple Developer Program)
2. **API Credentials** from App Store Connect
3. **GitHub Repository Secrets** for secure credential storage
4. **Code Signing Certificates** (optional, for direct signing)

---

## 🎯 Step 1: Create App Store Connect App

### 1.1 Access App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Sign in with your Apple ID (Apple Developer Account required)
3. Click **"My Apps"** in the sidebar

### 1.2 Create a New App

1. Click the **"+"** button and select **"New App"**
2. Fill in the details:
   - **Platform**: iOS
   - **Name**: RestroHub
   - **Primary Language**: English
   - **Bundle ID**: `com.portfolio.restrohub` (must match your Xcode project)
   - **SKU**: `restrohub-2025` (unique identifier)
   - **User Access**: Select appropriate access level

3. Click **"Create"**

### 1.3 Configure App Information

1. Navigate to **App Information**
2. Fill in:
   - **Subtitle**: Fast Food Delivery
   - **Privacy Policy URL**: (Optional)
   - **Category**: Food & Drink
   - **Content Rights**: Confirm content ownership

3. Save changes

---

## 🔑 Step 2: Generate App Store Connect API Credentials

### 2.1 Create API Key

1. In App Store Connect, go to **Users and Access** (top navigation)
2. Click on the **"Keys"** tab
3. Click the **"+"** button under **App Store Connect API**
4. Fill in:
   - **Name**: `RestroHub-GitHub-Actions` (descriptive name)
   - **Access Level**: **Admin** (required for TestFlight uploads)
5. Click **"Generate"**

### 2.2 Download and Store Key

1. **IMPORTANT**: Download the `.p8` key file immediately (can only download once!)
2. Save it securely, you'll need it in the next step
3. Note the following information:
   - **Issuer ID** (shown on the Keys page)
   - **Key ID** (shown next to the key name)

---

## 🔐 Step 3: Add GitHub Repository Secrets

### 3.1 Prepare Credentials

**Option A: If using API Key (Recommended)**

1. Open the downloaded `.p8` file in a text editor
2. Convert to base64 (single line, no newlines):

   **macOS/Linux:**
   ```bash
   cat ~/Downloads/AuthKey_XXXXX.p8 | base64 | tr -d '\n'
   ```

   **Windows (PowerShell):**
   ```powershell
   [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Path\To\AuthKey_XXXXX.p8")) -replace "`n"
   ```

3. Copy the base64 output (will be very long)

### 3.2 Add Secrets to GitHub

1. Go to your GitHub repository: `https://github.com/devmilang99/RestroHub`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**

**Add these 3 secrets:**

#### Secret 1: `APP_STORE_CONNECT_ISSUER_ID`
- **Name**: `APP_STORE_CONNECT_ISSUER_ID`
- **Value**: Your Issuer ID (from App Store Connect Keys page)
- **Example**: `12345678-1234-1234-1234-123456789012`

#### Secret 2: `APP_STORE_CONNECT_API_KEY_ID`
- **Name**: `APP_STORE_CONNECT_API_KEY_ID`
- **Value**: Your Key ID (short code shown next to key)
- **Example**: `ABC123DEFG`

#### Secret 3: `APP_STORE_CONNECT_API_PRIVATE_KEY`
- **Name**: `APP_STORE_CONNECT_API_PRIVATE_KEY`
- **Value**: Base64-encoded `.p8` file content (from step 3.1)
- **Example**: `MIGfMA0GCSqGSIb3DQEBAQUAA4GN...` (very long string)

### 3.3 Verify Secrets Added

Go to **Settings** → **Secrets and variables** → **Actions** and confirm all 3 appear in the list.

---

## 📝 Step 4: Configure Xcode Project (Bundle ID)

### 4.1 Update Bundle ID

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project in left sidebar
3. Select **Runner** target
4. Go to **Build Settings** tab
5. Search for **"Bundle Identifier"**
6. Set to: `com.portfolio.restrohub`

### 4.2 Verify in pubspec.yaml

Ensure your Flutter project has the correct iOS configuration:

```yaml
ios:
  bundleIdentifier: com.portfolio.restrohub
```

---

## 🔏 Step 5 (Optional): Set Up Code Signing Certificates

> This step is optional. Without it, the workflow will generate unsigned IPAs as artifacts.

### 5.1 Create Distribution Certificate

1. Go to [Apple Developer Certificate Manager](https://developer.apple.com/account/resources/certificates/list)
2. Click **"+"** to add a new certificate
3. Select **"Apple Distribution"**
4. Follow the prompts to:
   - Create a Certificate Signing Request (CSR) in Keychain Access
   - Upload the CSR
   - Download the certificate (.cer file)

### 5.2 Export to .p12 Format

1. Open Keychain Access on your Mac
2. Find the distribution certificate
3. Right-click → **Export** as `.p12` file
4. Set a strong password when prompted
5. Save the file

### 5.3 Encode and Add to GitHub Secrets

Convert `.p12` to base64:

**macOS/Linux:**
```bash
cat ~/Downloads/Certificates.p12 | base64 | tr -d '\n'
```

**Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Path\To\Certificates.p12")) -replace "`n"
```

Add as GitHub Secrets:

- **`IOS_DISTRIBUTION_CERT`**: Base64-encoded .p12 file
- **`IOS_DISTRIBUTION_CERT_PASSWORD`**: Password you set when exporting

### 5.4 Create Provisioning Profile

1. Go to [Apple Developer Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
2. Click **"+"** to create a new profile
3. Select **"App Store Connect"**
4. Select the RestroHub app
5. Select the distribution certificate
6. Download and encode as base64

Add to GitHub Secrets:

- **`IOS_PROVISIONING_PROFILE`**: Base64-encoded provisioning profile

---

## 🚀 Step 6: Trigger the Workflow

### 6.1 Push to Main Branch

```bash
git add .
git commit -m "chore: update iOS configuration"
git push origin main
```

### 6.2 Monitor Workflow

1. Go to your GitHub repo → **Actions** tab
2. Click the latest workflow run
3. Watch for:
   - ✅ `test` job (should pass)
   - ✅ `android_debug` job (should complete)
   - ✅ `ios_build` job (should complete)
   - ✅ `ios_testflight` job (should upload to TestFlight if secrets are set)

### 6.3 Check Artifacts

Once the workflow completes:

1. Click the workflow run
2. Scroll down to **Artifacts**
3. You should see:
   - `RestroHub-Debug-APK` (Android)
   - `RestroHub-iOS-Build` (iOS app bundle)
   - `RestroHub-iOS-TestFlight-IPA` (if signing failed, fallback IPA)

---

## 🧪 Step 7: Add Build to TestFlight

### 7.1 Verify Build in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select **RestroHub** app
3. Click **TestFlight** tab (left sidebar)
4. Look for your build under **"Builds"** section

> Note: Builds take 5-30 minutes to process after upload

### 7.2 Add Internal Testers

1. In TestFlight tab, click **"Internal Testers"**
2. Click **"+"** to add testers
3. Add your Apple ID email or team members' emails
4. TestFlight will send invitations

### 7.3 Add External Testers (Optional)

1. Click **"External Testers"**
2. Enter tester emails or create a **Public Link**
3. Submit for Apple review (takes ~24 hours)
4. Once approved, share the public link

---

## 🔗 Step 8: Get TestFlight Public Link

### 8.1 Create Public Link

1. In App Store Connect → TestFlight → External Testers
2. Click **"Create Link"** button
3. Set expiration date (up to 30 days)
4. Copy the link generated

### 8.2 Update iOS Download Guide

Update `IOS_DOWNLOAD_GUIDE.md` with your TestFlight link:

Replace this line:
```markdown
**⬇️ [Download via TestFlight](https://testflight.apple.com/join/YOUR_PUBLIC_LINK)**
```

With your actual link:
```markdown
**⬇️ [Download via TestFlight](https://testflight.apple.com/join/abc123def456ghi)**
```

---

## 🐛 Troubleshooting

### Workflow Fails on `ios_testflight`

**Error**: `"Provisioning profile not found"`

**Solution**: 
- Set `IOS_PROVISIONING_PROFILE` secret with valid base64 profile
- Or remove the secret to generate unsigned IPA instead

### Build Doesn't Appear in TestFlight

**Issue**: Build uploaded but not in App Store Connect

**Solution**:
1. Wait 5-30 minutes for processing
2. Check workflow logs for errors
3. Verify Bundle ID matches in Xcode and App Store Connect

### "Invalid provisioning profile"

**Solution**:
1. Re-export provisioning profile from Apple Developer
2. Re-encode to base64
3. Update the GitHub secret

### GitHub Secret Not Recognized

**Solution**:
1. Verify secret name is exactly: `APP_STORE_CONNECT_ISSUER_ID` (case-sensitive)
2. Go to **Settings** → **Secrets** and confirm it's listed
3. Delete and recreate the secret

---

## 📊 Monitoring Future Builds

Once set up, every push to `main` or `develop` will:

1. ✅ Run tests
2. ✅ Build Android APK
3. ✅ Build iOS artifacts
4. ✅ (If secrets set) Deploy to TestFlight automatically

**To check build status:**
- Go to GitHub → **Actions** tab
- Click any workflow run
- View logs and download artifacts

---

## 🔄 Workflow Triggers

| Branch | Event | Action |
|--------|-------|--------|
| `main` | Push | Build + Deploy to TestFlight |
| `develop` | Push | Build + Deploy to TestFlight |
| Any | Pull Request | Build only (no deployment) |

---

## 📞 Support Resources

- **App Store Connect Help**: [https://developer.apple.com/help/app-store-connect/](https://developer.apple.com/help/app-store-connect/)
- **TestFlight Docs**: [https://developer.apple.com/testflight/](https://developer.apple.com/testflight/)
- **GitHub Actions Docs**: [https://docs.github.com/en/actions](https://docs.github.com/en/actions)
- **Flutter iOS Deployment**: [https://docs.flutter.dev/deployment/ios](https://docs.flutter.dev/deployment/ios)

---

## ✅ Checklist

- [ ] Created App Store Connect account
- [ ] Created RestroHub app in App Store Connect
- [ ] Generated API Key (.p8 file)
- [ ] Added `APP_STORE_CONNECT_ISSUER_ID` secret
- [ ] Added `APP_STORE_CONNECT_API_KEY_ID` secret
- [ ] Added `APP_STORE_CONNECT_API_PRIVATE_KEY` secret
- [ ] Updated Bundle ID in Xcode (`com.portfolio.restrohub`)
- [ ] Pushed changes to GitHub
- [ ] Verified workflow completed successfully
- [ ] Checked build appears in App Store Connect TestFlight
- [ ] Created TestFlight public link
- [ ] Updated `IOS_DOWNLOAD_GUIDE.md` with TestFlight link

---

**Last Updated:** August 19, 2026  
**Repository:** [devmilang99/RestroHub](https://github.com/devmilang99/RestroHub)
