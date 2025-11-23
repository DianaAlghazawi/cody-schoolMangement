# Build Release AAB for Google Play Console

## 🚀 Quick Command

```bash
flutter build appbundle --release
```

---

## 📋 Step-by-Step Instructions

### 1. **Prerequisites**

Make sure you have:
- ✅ Production keystore generated
- ✅ `android/key.properties` file configured
- ✅ All dependencies installed

### 2. **Generate Keystore (If Not Done)**

If you haven't created a keystore yet:

```bash
cd android
./setup_release_signing.sh
```

Or manually:
```bash
keytool -genkey -v -keystore ~/classhub-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias classhub
```

### 3. **Configure key.properties**

Create or update `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=classhub
storeFile=/path/to/classhub-keystore.jks
```

**Important:** Use absolute path for `storeFile` or relative path from `android/` directory.

### 4. **Clean Build (Recommended)**

```bash
flutter clean
flutter pub get
```

### 5. **Build Release AAB**

```bash
flutter build appbundle --release
```

---

## 📁 Output Location

After building, your AAB file will be at:

```
build/app/outputs/bundle/release/app-release.aab
```

---

## 📦 Additional Files to Upload

### R8 Mapping File (Important!)

For crash reporting, also upload:

```
build/app/outputs/mapping/release/mapping.txt
```

**Location in Play Console:**
- Go to your app → Release → Production
- Select the version
- Scroll to "App bundles and APKs"
- Click "Upload" next to "ProGuard/R8 mapping file"

---

## ✅ Verification

After building, verify:

1. **Check file exists:**
   ```bash
   ls -lh build/app/outputs/bundle/release/app-release.aab
   ```

2. **Check file size:**
   - Should be reasonable (typically 10-50 MB depending on assets)
   - Much smaller than APK

3. **Check signing:**
   ```bash
   jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
   ```

---

## 🎯 Complete Build Workflow

```bash
# 1. Clean previous builds
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release AAB
flutter build appbundle --release

# 4. Verify output
ls -lh build/app/outputs/bundle/release/app-release.aab

# 5. (Optional) Check signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## 📤 Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to **Release** → **Production** (or your release track)
4. Click **Create new release**
5. Upload `app-release.aab`
6. Upload `mapping.txt` (R8 mapping file)
7. Fill in release notes
8. Review and roll out

---

## ⚠️ Important Notes

### Keystore Security
- **Keep your keystore safe!** If you lose it, you cannot update your app
- Back up `classhub-keystore.jks` securely
- Never commit keystore to version control
- `key.properties` is already in `.gitignore`

### Build Configuration
- Your `build.gradle.kts` is already configured for release signing
- It will use release keystore if `key.properties` exists
- Falls back to debug signing if keystore not found (for testing only)

### Version Information
- Version is controlled by `pubspec.yaml`:
  ```yaml
  version: 1.0.0+1
  ```
  - `1.0.0` = version name (shown to users)
  - `1` = version code (must increment for each upload)

---

## 🔧 Troubleshooting

### Error: "Keystore file not found"
- Check `key.properties` has correct path
- Use absolute path or path relative to `android/` directory

### Error: "Keystore password incorrect"
- Verify passwords in `key.properties` match keystore

### Error: "Signing config not found"
- Make sure `key.properties` exists in `android/` directory
- Check file permissions

### Build succeeds but AAB is signed with debug certificate
- Check that `key.properties` exists and is readable
- Verify keystore path is correct
- Check build logs for signing errors

---

## 📝 Quick Reference

| Command | Purpose |
|---------|---------|
| `flutter build appbundle --release` | Build release AAB |
| `flutter build apk --release` | Build release APK (for testing) |
| `flutter clean` | Clean build artifacts |
| `flutter pub get` | Get dependencies |

---

**That's it!** Your AAB is ready for Google Play Console submission. 🎉

