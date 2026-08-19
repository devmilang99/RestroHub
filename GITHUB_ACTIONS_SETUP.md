# 🔧 GitHub Actions & Build Artifacts Guide

> This guide walks you through the CI/CD pipeline of RestroHub, which automatically generates Android APKs and iOS IPAs for testing.

---

## 📋 CI/CD Overview

The RestroHub CI/CD workflow (`flutter_ci.yml`) is designed to automate testing and build generation. It runs on every push and pull request to the `main` and `develop` branches.

### 🏗️ Workflow Jobs

1.  **Run Tests**: Executes all unit and widget tests on a Linux runner.
2.  **Build Android Debug APK**: Compiles a debug APK for Android and uploads it as an artifact.
3.  **Build iOS App Bundle & IPA**: Compiles an unsigned iOS application on a macOS runner and packages it as an `.ipa` file for cloud testing.
4.  **Create GitHub Release**: On pushes to `main`, it downloads the built artifacts and creates a new "Latest Build" release with permanent download links.

---

## 🔐 GitHub Repository Secrets

To ensure the CI/CD runs correctly, the following secrets should be configured in **Settings → Secrets and variables → Actions**:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous API key | Yes |
| `GEMINI_API_KEY` | Your Google Gemini API key | Yes |
| `GOOGLE_WEB_CLIENT_ID`| Client ID for Google Sign-In | Yes |

---

## 📦 Accessing Build Artifacts

### 1. GitHub Actions (Per-Build)
- Go to the **Actions** tab.
- Click on a specific workflow run.
- Scroll down to the **Artifacts** section to download specific build files (valid for 90 days).

### 2. GitHub Releases (Permanent)
- Go to the **Releases** section on the repository homepage.
- The `latest` release always contains the most recent successful builds from the `main` branch:
    - `RestroHub-Android.apk`
    - `RestroHub-iOS.ipa`

---

## 🧪 Testing the iOS IPA (No Mac Required)

Since the generated iOS build is **unsigned**, it cannot be installed directly on a physical iPhone without an Apple Developer account. However, you can test it easily using **BrowserStack**:

1. Download the `RestroHub-iOS.ipa` from the latest release.
2. Upload it to [BrowserStack App Live](https://www.browserstack.com/app-live).
3. BrowserStack will resign the app and allow you to test it on real cloud devices.

---

## 🛠️ Modifying the Workflow

The workflow file is located at [.github/workflows/flutter_ci.yml](.github/workflows/flutter_ci.yml).

### Changing Retention Days
If you want artifacts to expire sooner or later (up to 90 days), modify the `retention-days` property:
```yaml
      - name: Upload Android APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: RestroHub-Debug-APK
          path: build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 90 # Change this value
```

---

## 🔄 Workflow Triggers

| Branch | Event | Action |
|--------|-------|--------|
| `main` | Push | Tests + Build + **Create/Update Release** |
| `develop` | Push | Tests + Build |
| Any | Pull Request | Tests + Build (No Release) |

---

**Last Updated:** August 19, 2026  
**Repository:** [milan-ghimire/RestroHub](https://github.com/milan-ghimire/RestroHub)
