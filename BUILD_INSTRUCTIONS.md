# Build Instructions for ClassHub

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter --version
   ```

2. **Android Studio** with:
   - Android SDK (API 34)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools

3. **Java Development Kit (JDK)** 8 or higher
   ```bash
   java -version
   ```

4. **Android NDK** (if not included with Android Studio)

## Setup Steps

### 1. Clone/Download the Project

```bash
cd /path/to/cody-schoolMangement
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Verify Flutter Setup

```bash
flutter doctor
```

Ensure all required components are installed and configured.

### 4. Android Configuration

#### 4.1. Configure Local Properties

Create or edit `android/local.properties`:

```properties
sdk.dir=/path/to/Android/sdk
flutter.sdk=/path/to/flutter
```

#### 4.2. Generate Keystore (for Release Builds)

```bash
keytool -genkey -v -keystore ~/classhub-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias classhub
```

#### 4.3. Configure Signing (Release Builds)

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=classhub
storeFile=/path/to/classhub-keystore.jks
```

Update `android/app/build.gradle` to use the keystore:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

## Building the App

### Debug Build

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## R8 Mapping File (ProGuard/R8)

### Location

After building a release APK/AAB, the R8 mapping file is located at:

```
build/app/outputs/mapping/release/mapping.txt
```

### Uploading to Google Play Console

1. **Build the release AAB:**
   ```bash
   flutter build appbundle --release
   ```

2. **Locate the mapping file:**
   ```bash
   ls -la build/app/outputs/mapping/release/mapping.txt
   ```

3. **Upload to Play Console:**
   - Go to Google Play Console
   - Navigate to your app
   - Go to **Release** > **Production** (or your release track)
   - Select the version
   - Scroll to **App bundles and APKs**
   - Click **Upload** next to "ProGuard/R8 mapping file"
   - Upload `mapping.txt`

### Why Upload R8 Mapping?

- Enables crash reporting with readable stack traces
- Required for deobfuscating crash reports
- Helps Google Play Console analyze crashes
- Essential for debugging production issues

### Verifying R8 is Enabled

Check `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## Testing

### Run Unit Tests

```bash
flutter test
```

### Run Widget Tests

```bash
flutter test test/widgets/
```

### Run on Device/Emulator

```bash
flutter run
```

## Troubleshooting

### Common Issues

1. **Gradle Build Fails**
   - Ensure Java 8+ is installed
   - Clean build: `cd android && ./gradlew clean && cd ..`
   - Invalidate caches in Android Studio

2. **Permission Errors**
   - Check `AndroidManifest.xml` permissions
   - Verify target SDK is 34

3. **R8 Mapping Not Generated**
   - Ensure `minifyEnabled true` in release build type
   - Build release AAB, not just APK
   - Check `build/app/outputs/mapping/release/` directory

4. **Dependencies Issues**
   - Run `flutter pub get`
   - Delete `pubspec.lock` and run `flutter pub get` again
   - Check Flutter version compatibility

### Clean Build

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build appbundle --release
```

## Release Checklist

Before uploading to Play Console:

- [ ] Version code and version name updated in `pubspec.yaml`
- [ ] All tests passing (`flutter test`)
- [ ] Release build successful
- [ ] R8 mapping file generated
- [ ] Privacy policy uploaded to Play Console
- [ ] App signing configured
- [ ] Permissions reviewed and justified
- [ ] Accessibility tested
- [ ] Offline functionality verified
- [ ] No sensitive data in logs or code

## Version Information

- **App Version**: 1.0.0+1
- **Package Name**: com.classhub.app
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Android Developer Guide](https://developer.android.com)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [R8 Documentation](https://developer.android.com/studio/build/shrink-code)

---

**Note**: Always test release builds thoroughly before uploading to Play Console. The R8 mapping file is crucial for crash reporting and must be uploaded with each release.

