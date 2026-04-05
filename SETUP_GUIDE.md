# Sign Language Translator - Setup Guide

## Prerequisites

- Flutter SDK (latest version)
- Python 3.8+
- Firebase Project
- Google Cloud Console access

## Project Structure

```
sign_translate/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/                  # UI Screens
│   │   ├── auth_screen.dart      # Authentication
│   │   ├── home_screen.dart      # Home page
│   │   ├── camera_screen.dart    # Camera detection
│   │   ├── result_screen.dart    # Results display
│   │   └── history_screen.dart   # Translation history
│   ├── services/
│   │   ├── firebase_service.dart # Firebase integration
│   │   ├── sign_language_service.dart # API client
│   │   └── storage_service.dart  # Local storage
│   ├── providers/
│   │   └── auth_provider.dart    # State management
│   ├── widgets/
│   │   └── app_widgets.dart      # Reusable widgets
│   └── theme/
│       └── app_theme.dart        # Theme configuration
└── pubspec.yaml
```

## Setup Instructions

### 1. Backend Setup (FastAPI)

```bash
cd SignLanguageAI
python -m venv venv

# Windows
venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt

# Run the server
python server.py
```

The API will be available at `http://localhost:8000`
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### 2. Firebase Configuration

#### a. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Fill in the project details
4. Enable Google Analytics (optional)
5. Create the project

#### b. Register Flutter App

1. In Firebase Console, click "Add app" → Flutter
2. Register iOS and Android separately
3. Download `GoogleService-Info.plist` for iOS
4. Download `google-services.json` for Android

#### c. Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Enable **Google** (configure OAuth consent screen)

#### d. Enable Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **Production mode**
4. Choose a region
5. Set security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /translations/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /favorites/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /stats/{doc=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

#### e. Configure Flutter for Firebase

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your project:
```bash
cd sign_translate
flutterfire configure
```

This will create `lib/services/firebase_options.dart` automatically.

### 3. Update Firebase Configuration

Edit `lib/services/firebase_options.dart` with your Firebase credentials:

```dart
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
  
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.signTranslate',
  );
}
```

### 4. Flutter App Setup

```bash
cd sign_translate

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## API Endpoints

### Health Check
```
GET /health
```

### Predict from Image
```
POST /predict/image
Content-Type: multipart/form-data

Response:
{
  "gesture": "hello",
  "confidence": 0.95,
  "timestamp": "2024-04-05T10:30:00Z",
  "all_predictions": {
    "hello": 0.95,
    "goodbye": 0.03,
    "thanks": 0.02
  }
}
```

### Get Available Classes
```
GET /models/classes

Response:
{
  "total_classes": 50,
  "classes": ["hello", "goodbye", "thanks", ...]
}
```

## Features

### Authentication
- Email/Password sign-up and sign-in
- Google Sign-In
- Password reset
- User profile management

### Translation
- Real-time gesture detection via camera
- Confidence scores
- Translation history (persisted in Firestore)
- Favorites management

### Analytics
- User statistics (translations count, average confidence)
- Usage tracking
- Translation patterns

## Environment Variables

Create `.env` file in `SignLanguageAI` directory:

```env
# Server
HOST=0.0.0.0
PORT=8000

# Database
MODEL_PATH=models/model.keras
WORDS_PATH=models/words.pkl
```

## Troubleshooting

### Firebase Initialization Error
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly placed
- Run `flutterfire configure` again

### API Connection Issues
- Check if FastAPI server is running on `http://localhost:8000`
- Update `baseUrl` in `sign_language_service.dart` for remote server

### No Hand Detected
- Ensure good lighting
- Keep hand clearly visible in camera
- Try different hand positions

### Low Confidence Scores
- Retrain the model with more diverse gesture samples
- Ensure consistent lighting conditions
- Check camera resolution and focus

## Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Security Best Practices

1. Never commit Firebase credentials to git
2. Use environment variables for sensitive data
3. Implement rate limiting on API endpoints
4. Use HTTPS for all API calls
5. Validate user inputs on both client and server
6. Keep dependencies updated

## Support

For issues or questions, contact: [your email]
