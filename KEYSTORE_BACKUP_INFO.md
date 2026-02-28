# Masoko Tips Keystore Backup - CRITICAL

## Keystore Location
- **Primary:** `android/upload-keystore.jks`
- **Backup in app:** `android/app/upload-keystore.jks`
- **Also copied to root:** `upload-keystore.jks`

## Credentials (KEEP SECRET!)
- **Store Password:** masoko123
- **Key Password:** masoko123
- **Key Alias:** upload

## Certificate Fingerprint (SHA1)
`34:69:56:D9:59:3A:47:96:3E:51:5F:3B:0C:1C:00:D2:F1:E4:B4:4C`

---

# How to Safely Backup Your Keystore

## 1. Manual Backup (Recommended)
Copy the keystore file to multiple secure locations:
- External USB drive
- Cloud storage (Google Drive, Dropbox)
- Password manager (as attachment)

## 2. Never Do This:
- ❌ Commit keystore to git
- ❌ Share keystore passwords in email
- ❌ Store keystore in public folders

## 3. Best Practice for Future:
- Store keystore in a password-protected folder
- Use a password manager to store the keystore credentials
- Keep a backup on external storage (USB drive)
- Email the keystore to yourself for cloud backup

## 4. If You Lose the Keystore Again:
1. Contact Google Play Developer Support
2. They may allow you to reset the upload key
3. You'll need to create a new keystore
4. Existing users will NOT receive updates (new install only)

---

**IMPORTANT:** This keystore is now valid as of Feb 19, 2026. Use it for all future updates to maintain continuity for existing users.
