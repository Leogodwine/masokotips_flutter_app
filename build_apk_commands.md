# 🔨 Build APK Commands

## Quick Build Commands (Run in this order):

### Step 1: Navigate to your Flutter project
```bash
cd d:\flutterProjects\masoko_tips
```

### Step 2: Clean previous builds
```bash
flutter clean
```

### Step 3: Get dependencies
```bash
flutter pub get
```

### Step 4: Build the signed APK
```bash
flutter build apk --release
```

### Step 5: Locate your APK
After building, your APK will be at:
```
d:\flutterProjects\masoko_tips\build\app\outputs\flutter-apk\app-release.apk
```

## ✅ Expected Result:
- Build should complete without keystore errors
- APK should be properly signed with your keystore
- APK should install successfully without "invalid package" errors

## 🔍 If Build Fails:
Share the exact error message and I'll help troubleshoot.

## 📱 Installation Testing:
1. **Uninstall** any old versions of the app from your device
2. **Enable** "Install unknown apps" for your file manager
3. **Transfer** the APK to your device
4. **Install** - should work perfectly now!