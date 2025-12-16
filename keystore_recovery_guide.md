# Keystore Recovery Guide

## 🚨 Critical: Play Store App Keystore

Since your app is already published on Play Store, you MUST use the same keystore for all updates.

## Step 1: Check Common Locations for Passwords

Look for your keystore passwords in these places:

1. **Previous build scripts** - Look for commands containing:
   ```bash
   keyAlias=upload
   storePassword=your_password
   keyPassword=your_password
   ```

2. **Flutter build commands** with keystore parameters

3. **CI/CD configuration files** (GitHub Actions, GitLab CI, etc.)

4. **Documentation or README files**

5. **Email history** - Search for emails containing "keystore" or "upload"

## Step 2: Try Common Passwords

Common default passwords for upload keystores:
- `upload`
- `android`
- `password`
- `123456`
- Your app name in lowercase
- Your company name

## Step 3: Key Alias Names

Common key alias names:
- `upload`
- `key0`
- `masoko_tips`
- Your app package name

## Step 4: Use Keytool to Check Keystore

Run this command to inspect your keystore:

```bash
keytool -list -v -keystore upload-keystore.jks
```

This will show you:
- Key aliases available
- When the keystore was created
- Certificate details

## Step 5: Alternative Recovery Methods

1. **Check if you have key.properties.bak or similar backup files**

2. **Look in your git history** for previous key.properties files

3. **Contact your team members** who might have access to the credentials

## Step 6: Last Resort Options

If you absolutely cannot recover the keystore:
- Contact Google Play Console support
- Explain the situation (they may help with keystore recovery)
- **DO NOT** create new keystore unless absolutely necessary

## 🔒 Security Note

Never share keystore passwords publicly or commit them to version control. Store them securely in environment variables or encrypted files.