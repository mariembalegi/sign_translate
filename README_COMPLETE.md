# Sign Language Translator

🤟 A real-time gesture recognition app powered by AI/ML that translates sign language using your device camera.

## Features

✨ **Core Features**
- 🎥 Real-time gesture detection via camera
- 🤖 TensorFlow Keras model for gesture recognition
- 📱 Flutter cross-platform mobile app
- ☁️ Firebase backend for data persistence
- 👤 User authentication (Email/Google Sign-In)
- 📊 Translation history with statistics
- ❤️ Favorite gestures management
- 🌙 Dark mode support

🔧 **Tech Features**
- RESTful API with FastAPI
- Cloud Firestore for real-time database
- Role-based access control
- Confidence scoring
- Batch prediction support

## Project Structure

```
sign_translate/                  # Flutter App
├── lib/
│   ├── main.dart
│   ├── screens/                # UI Pages
│   ├── services/               # API & Firebase
│   ├── providers/              # State Management
│   ├── widgets/                # Reusable Components
│   └── theme/                  # Design System
├── pubspec.yaml
├── SETUP_GUIDE.md
└── FIREBASE_SETUP.md

SignLanguageAI/                 # Backend & ML
├── scripts/
│   ├── train.py               # Model training
│   └── test_cam.py            # Camera testing
├── models/
│   ├── model.keras            # Trained model
│   └── words.pkl              # Labels
├── server.py                  # FastAPI server
└── requirements.txt
```

## Requirements

- **Flutter**: 3.19.0+
- **Dart**: 3.5.0+
- **Python**: 3.8+
- **Firebase**: Active project
- **TensorFlow**: 2.14.0+

## Quick Start

### 1️⃣ Backend Setup

```bash
cd SignLanguageAI

# Create virtual environment
python -m venv venv

# Activate
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the API server
python server.py
```

Server will be available at: `http://localhost:8000`
- API Docs: `http://localhost:8000/docs`

### 2️⃣ Firebase Configuration

1. Create a Firebase project: https://console.firebase.google.com
2. Enable Authentication (Email/Password + Google)
3. Create Firestore Database
4. Follow [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) for detailed instructions

### 3️⃣ Flutter App Setup

```bash
cd sign_translate

# Get dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

## API Documentation

### Base URL
```
http://localhost:8000
```

### Endpoints

#### Health Check
```http
GET /health
```

#### Predict from Image
```http
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

#### Get Available Classes
```http
GET /models/classes

Response:
{
  "total_classes": 50,
  "classes": ["hello", "goodbye", "thanks", ...]
}
```

See full API docs at `/docs` (Swagger UI) or `/redoc` (ReDoc)

## Configuration

### API Server URL

Edit in `lib/services/sign_language_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8000'; // Change for production
```

### Firebase Settings

All settings are auto-configured via `flutterfire configure`. Manual config in:
- `lib/services/firebase_options.dart`

### App Settings

Accessible via Settings screen in the app:
- Server URL
- Confidence threshold
- Dark mode toggle

## Database Schema

### Firestore Collections

#### `/users/{userId}`
User profile and settings

#### `/users/{userId}/translations`
Translation history with confidence scores

#### `/users/{userId}/favorites`
User's favorite gestures

#### `/users/{userId}/stats/overview`
Aggregated user statistics

## State Management

Using **Provider** pattern for:
- `AuthProvider`: Authentication & user state
- `TranslationProvider`: Translations & favorites

Example:
```dart
Consumer<AuthProvider>(
  builder: (_, authProvider, __) {
    if (authProvider.isAuthenticated) {
      // Show authenticated UI
    }
  },
)
```

## Screens

### Home Screen
- Welcome card
- Quick action buttons
- User statistics
- Recent translations

### Camera Screen
- Real-time gesture detection
- Live confidence indicator
- Result display

### History Screen
- All past translations
- Favorite toggle
- Search & filter

### Favorites Screen
- Grid of favorite gestures
- Quick access
- Manage collection

### Auth Screen
- Email/Password auth
- Google Sign-In
- Sign up & Sign in

## Styling

### Theme System
- Light & Dark modes
- Consistent color scheme
- Custom typography
- Reusable components

See `lib/theme/app_theme.dart`

## Performance Optimizations

- ✅ Lazy loading for translations
- ✅ Image caching
- ✅ Batch predictions
- ✅ Debounced API calls
- ✅ Efficient Firestore queries

## Security

- 🔒 Firebase security rules (user-scoped access)
- 🔒 Input validation
- 🔒 HTTPS for all API calls
- 🔒 No sensitive data in logs
- 🔒 Rate limiting on backend

## Error Handling

- Network errors → Retry logic
- Firebase errors → User-friendly messages
- Validation errors → Input feedback
- Model errors → Fallback UI

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Build APK for testing
flutter build apk --debug
```

## Deployment

### Android
```bash
flutter build apk --release
# or for app bundle (Google Play):
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Then use Xcode to sign and distribute
```

### Backend Deployment

Deploy FastAPI server to:
- AWS EC2
- Google Cloud Run
- Heroku
- Your own server

Example with Gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 server:app
```

## Model Training

Update the gesture recognition model:

```bash
cd SignLanguageAI/scripts

# Prepare your dataset
python train.py

# Test with camera
python test_cam.py
```

Dataset format:
```
dataset/
├── category_1/
│   ├── gesture_1/
│   │   ├── 0.jpg
│   │   ├── 1.jpg
│   │   └── ...
└── category_2/
    └── ...
```

## Troubleshooting

### App crashes on startup
```bash
flutter clean
flutter pub get
flutter run
```

### Firebase authentication fails
- Ensure `GoogleService-Info.plist` and `google-services.json` are in correct locations
- Run `flutterfire configure` again

### No hand detected
- Check lighting
- Keep hand clearly visible
- Try different positions

### Low confidence scores
- Retrain model with more data
- Check camera resolution
- Ensure consistent gestures

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues or questions:
- Open an issue on GitHub
- Check the [SETUP_GUIDE.md](./SETUP_GUIDE.md)
- See [FIREBASE_SETUP.md](./FIREBASE_SETUP.md)

## Acknowledgments

- TensorFlow/Keras for ML framework
- Firebase for backend services
- Flutter for UI framework
- MediaPipe for hand detection

---

**Made with ❤️ for sign language accessibility**
