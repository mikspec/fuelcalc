# Google Drive Integration Setup

This document explains how to configure Google Drive export functionality in FuelCalc.

## Overview

The app now supports exporting SQLite database backups directly to Google Drive. This feature requires Google OAuth 2.0 authentication.

## Prerequisites

1. A Google Cloud Console account
2. An Android/iOS app configured in Google Cloud Console
3. OAuth 2.0 credentials for your app

## Setup Instructions

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google Drive API** for your project:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API"
   - Click "Enable"

### 2. Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" user type (or "Internal" if you have a Google Workspace)
3. Fill in the required information:
   - App name: FuelCalc
   - User support email: your email
   - Developer contact information: your email
4. Add scopes:
   - Click "Add or Remove Scopes"
   - Add: `https://www.googleapis.com/auth/drive.file`
5. Add test users (for testing phase)
6. Submit for verification (required for production)

### 3. Create OAuth 2.0 Credentials

#### For Android:

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "Android" as application type
4. Fill in:
   - Name: FuelCalc Android
   - Package name: `pl.mikspec.fuelcalc`
   - SHA-1 certificate fingerprint (get it using the command below)

To get your SHA-1 fingerprint:

```bash
# For debug builds
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release builds (use your actual keystore)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

#### For iOS:

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "iOS" as application type
4. Fill in:
   - Name: FuelCalc iOS
   - Bundle ID: `pl.mikspec.fuelcalc`

#### For Web:

1. Create an OAuth 2.0 Client ID for Web application
2. Add authorized JavaScript origins:
   - `http://localhost` (for local testing)
   - Your production domain

### 4. Download and Configure OAuth Client

1. Download the OAuth client configuration file (`google-services.json` for Android or `GoogleService-Info.plist` for iOS)
2. Place the files in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 5. Update Android Configuration

Add the following to `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Add this line
}
```

Add to `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")  // Add this line
    }
}
```

### 6. Update iOS Configuration

Add the following URL scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

## Testing

1. Build and run the app
2. Navigate to Backup screen
3. Click "Export to Google Drive"
4. Sign in with your Google account (must be a test user if app is not published)
5. Grant permissions to access Google Drive
6. The database will be uploaded to a folder called "FuelCalc_Backups" in your Google Drive

## Troubleshooting

### "Sign-in failed" error
- Check that your SHA-1 fingerprint is correct
- Verify that OAuth client ID is properly configured
- Make sure the package name matches exactly

### "Permission denied" error
- Verify that Google Drive API is enabled
- Check that the OAuth consent screen is properly configured
- Ensure you've added the correct scopes

### "Invalid client" error
- Verify that you're using the correct OAuth client ID for the platform
- Check that google-services.json or GoogleService-Info.plist is in the correct location

## Security Notes

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to version control
2. Add these files to `.gitignore`:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```
3. Use different OAuth clients for debug and release builds
4. Keep your keystore and credentials secure

## Production Deployment

Before releasing to production:

1. Submit your OAuth consent screen for verification
2. Use release keystore for Android SHA-1 fingerprint
3. Configure production OAuth clients
4. Test thoroughly with multiple accounts
5. Implement proper error handling and user feedback

## Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google APIs for Flutter](https://pub.dev/packages/googleapis)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Drive API Documentation](https://developers.google.com/drive/api/v3/about-sdk)
