# Firebase Configuration Guide

## Overview

This guide helps you set up Firebase for the Sign Language Translator app. Firebase provides:
- **Authentication**: Email/Password and Google Sign-In
- **Firestore**: Real-time database for translations, favorites, and statistics
- **Storage**: Cloud storage for multimedia files (future feature)
- **Analytics**: User behavior tracking

## Prerequisites

- Firebase project created at [firebase.google.com](https://firebase.google.com)
- Google Cloud Console access
- FlutterFire CLI installed

## Step-by-Step Setup

### 1. Create a Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter your project name (e.g., `sign-language-translator`)
4. Accept the terms and create the project
5. Skip Google Analytics setup (optional)

### 2. Register iOS and Android Apps

#### Register iOS App:
1. Click the iOS icon
2. Bundle ID: `com.example.sign_translate` (or your custom bundle)
3. Download `GoogleService-Info.plist`
4. In Xcode: Targets → Build Phases → Copy Bundle Resources → Add the downloaded file
5. No need to add the initialization code (FlutterFire handles it)

#### Register Android App:
1. Click the Android icon
2. Package name: `com.example.sign_translate`
3. Download `google-services.json`
4. Place it in `android/app/`
5. Ensure `android/build.gradle` includes:
```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

And `android/app/build.gradle` includes:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 3. Enable Authentication

1. Go to **Authentication** in Firebase Console
2. Click "Sign-in method"
3. Enable:
   - ✅ **Email/Password**
   - ✅ **Google**
   
For Google Sign-In:
- Click on Google
- Configure OAuth Consent Screen
- Add test users or make app available to all

### 4. Set Up Firestore Database

1. Go to **Firestore Database**
2. Click "Create Database"
3. Choose **Production mode**
4. Select a region (European servers recommended for GDPR)
5. Create the database

#### Security Rules

Replace the default security rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Translations collection
      match /translations/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Favorites collection
      match /favorites/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Statistics collection
      match /stats/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

### 5. Configure FlutterFire

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. In your project directory:
```bash
flutterfire configure
```

3. Select your Firebase project
4. This generates `lib/services/firebase_options.dart`

### 6. Update firebase_options.dart (if needed)

If `flutterfire configure` doesn't work, manually update `lib/services/firebase_options.dart`:

```dart
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_MESSAGING_SENDER_ID:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.signTranslate',
  );
}
```

Find these values in Firebase Console → Project Settings → Service Accounts → Generate new private key

## Database Schema

### Users Collection
```
/users/{userId}
├── email: string
├── displayName: string
├── photoURL: string
├── createdAt: timestamp
└── updatedAt: timestamp
```

### Translations Collection
```
/users/{userId}/translations/{translationId}
├── gesture: string
├── confidence: number (0-1)
├── notes: string
└── timestamp: timestamp
```

### Favorites Collection
```
/users/{userId}/favorites/{gesture}
├── gesture: string
└── addedAt: timestamp
```

### Statistics Collection
```
/users/{userId}/stats/overview
├── totalTranslations: number
├── avgConfidence: number (0-1)
└── lastTranslation: timestamp
```

## Testing

### Test with Emulator (Optional)

```bash
# Install Firebase emulator
npm install -g firebase-tools

# In your project
firebase emulators:start
```

Then connect your app to the emulator:
```dart
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

### Test Authentication

1. Run the app
2. Sign up with email/password
3. Sign in with Google
4. Check Firestore to see user document created

## Troubleshooting

### "No Project selected"
```bash
flutterfire configure --project=YOUR_PROJECT_ID
```

### "Permission denied" errors in Firestore
- Check security rules are correctly configured
- Ensure user is authenticated
- Check Firestore rules in console

### Google Sign-In not working
- Ensure OAuth consent screen is configured
- Add test users if app is in testing phase
- Check `ios/Podfile` has `platform :ios, '11.0'` or higher

### App crashes on initialization
- Run `flutter pub get`
- Run `flutter clean`
- Run `flutter pub upgrade`
- Rebuild the app

## Environment-Specific Configuration

### Development
```dart
const String firebaseProject = 'sign-translator-dev';
```

### Production
```dart
const String firebaseProject = 'sign-translator-prod';
```

## Privacy & Security

- ✅ Firestore rules are security rules, not access control
- ✅ Users can only access their own data
- ✅ Never expose Firebase API key in frontend
- ✅ Use Anonymous Authentication for public features if needed

## Monitoring

### Firebase Console
- **Authentication**: Monitor user growth
- **Firestore**: Check database usage and reads/writes
- **Performance**: Track app performance metrics
- **Analytics**: Understand user behavior

### Recommended Quotas
- Free tier: Good for testing (max 50,000 reads/day)
- Blaze tier: Pay as you go (recommended for production)

## Backup & Export

To export Firestore data:
1. Go to **Firestore Database**
2. Click **⋮** (menu) → **Export collection**
3. Choose destination in Google Cloud Storage

## Next Steps

1. ✅ Firebase project created
2. ✅ Authentication enabled
3. ✅ Firestore database ready
4. ✅ Security rules configured
5. 🔄 Run the Flutter app
6. 🔄 Test authentication
7. 🔄 Verify data storage

For more info: [Firebase Documentation](https://firebase.flutter.dev/)
