# Setup Checklist ✅

Use this checklist to configure your Sign Language Translator app.

---

## Phase 1: Firebase Setup

### Create Firebase Project
- [ ] Go to https://console.firebase.google.com
- [ ] Click "Create project"
- [ ] Enter project name: `sign-language-translator`
- [ ] Accept terms and create

### Configure Authentication
- [ ] Go to **Authentication** → **Sign-in method**
- [ ] Enable **Email/Password**
  - [ ] Enable "Email link (passwordless sign-in)" if needed
- [ ] Enable **Google**
  - [ ] Configure OAuth consent screen
  - [ ] Add your email as test user (if in development)
  - [ ] Approve the Oauth app

### Set Up Firestore Database
- [ ] Go to **Firestore Database**
- [ ] Click **Create database**
- [ ] Choose **Production mode** (can change to test later)
- [ ] Select region (e.g., `europe-west1` for GDPR)
- [ ] Click **Create database**
- [ ] Go to **Rules** tab
- [ ] Replace with rules from FIREBASE_SETUP.md
- [ ] Publish the rules

### Note Firebase Credentials
- [ ] Go to **Project Settings** → **General**
- [ ] Note your **Project ID**
- [ ] Note your **Project Number**

---

## Phase 2: Configure Flutter App

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```
- [ ] Installation complete

### Register Android App
1. [ ] In Firebase Console, click **Add app** → Android
2. [ ] Package name: `com.example.sign_translate`
3. [ ] Debug signing certificate SHA-1: (leave empty for now)
4. [ ] Click "Register app"
5. [ ] Download `google-services.json`
6. [ ] Place in `sign_translate/android/app/google-services.json`

### Register iOS App
1. [ ] In Firebase Console, click **Add app** → iOS
2. [ ] Bundle ID: `com.example.sign_translate`
3. [ ] Download `GoogleService-Info.plist`
4. [ ] In Xcode: Open `ios/Runner.xcworkspace`
5. [ ] Drag `GoogleService-Info.plist` into Xcode
6. [ ] Ensure it's added to all targets

### Run FlutterFire Configure
```bash
cd sign_translate
flutterfire configure
```
- [ ] Select your Firebase project
- [ ] Confirm all prompts
- [ ] File `lib/services/firebase_options.dart` created

### Verify Configuration
```bash
flutter doctor -v
```
- [ ] No significant errors
- [ ] All dependencies installed

---

## Phase 3: Backend Setup

### Create Python Virtual Environment
```bash
cd ..  # Go back to parent
cd SignLanguageAI
python -m venv venv

# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```
- [ ] Virtual environment activated

### Install Dependencies
```bash
pip install -r requirements.txt
```
- [ ] All packages installed

### Verify Model Files
```bash
ls models/
# Should show: model.keras, words.pkl
```
- [ ] `models/model.keras` exists
- [ ] `models/words.pkl` exists

### Test Server Start
```bash
python server.py
```
- [ ] Server starts without errors
- [ ] Output shows: "Application startup complete"
- [ ] Visit `http://localhost:8000/docs` in browser
- [ ] Swagger UI loads
- [ ] Stop server (Ctrl+C)

---

## Phase 4: Flutter App Testing

### Install Dependencies
```bash
cd ../sign_translate
flutter pub get
```
- [ ] All dependencies downloaded
- [ ] No build errors

### Build Android (First Time)
```bash
flutter build apk
```
- [ ] Build completes successfully
- [ ] APK file created in `build/app/outputs/flutter-apk/`

### Run the App
```bash
flutter run
```
- [ ] App launches on device/emulator
- [ ] Welcome screen appears

### Test Authentication
- [ ] **Sign up with email**
  - [ ] Enter email and password
  - [ ] Account created
  - [ ] Auto-logged in
  
- [ ] **Sign out**
  - [ ] Tap menu → Sign Out
  - [ ] Back to login screen
  
- [ ] **Sign in with Google**
  - [ ] Tap "Sign in with Google"
  - [ ] Google login flow completes
  - [ ] Auto-logged in

### Verify Firebase Connection
- [ ] Go to Firebase Console → **Authentication**
- [ ] See your test user(s) listed
- [ ] Go to **Firestore Database**
- [ ] See `/users/{userId}` document created

### Test App Features
- [ ] Home screen loads
- [ ] Statistics displayed (initially 0)
- [ ] Quick action buttons visible
- [ ] Dark mode toggle works
- [ ] Can navigate to History (empty)
- [ ] Can navigate to Favorites (empty)

---

## Phase 5: Backend Integration

### Start Backend Server
```bash
cd SignLanguageAI
source venv/bin/activate  # or venv\Scripts\activate on Windows
python server.py
```
- [ ] Server running on `localhost:8000`

### Test API Endpoints
```bash
# In another terminal:

# 1. Health check
curl http://localhost:8000/health

# 2. Get available classes
curl http://localhost:8000/models/classes
```
- [ ] Both return JSON responses

### Update Server URL (if needed)
Edit `lib/services/sign_language_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:8000';
```
- [ ] URL updated if using remote server

### Test Camera Integration
- [ ] Open app on device with camera
- [ ] Go to "Sign to Text" screen
- [ ] Camera permission requested and granted
- [ ] Camera preview shows
- [ ] Perform a gesture in front of camera
- [ ] If backend running: Results appear below

---

## Phase 6: Data Testing

### Test Translation Recording
1. [ ] Perform camera gesture
2. [ ] See result appear
3. [ ] Go to History screen
4. [ ] See translation in history
5. [ ] Check Firebase console → `/users/{userId}/translations`
6. [ ] Translation document exists

### Test Favorites
1. [ ] In History, tap heart icon on a translation
2. [ ] Go to Favorites screen
3. [ ] See gesture card appears
4. [ ] Check Firebase → `/users/{userId}/favorites`
5. [ ] Favorite document exists

### Test Statistics
1. [ ] Make 3-5 translations
2. [ ] Check Home screen statistics
3. [ ] Should show "Total Translations: X"
4. [ ] Check Firebase → `/users/{userId}/stats/overview`
5. [ ] Should have `totalTranslations` and `avgConfidence`

---

## Phase 7: Deployment (Optional)

### Android APK Release
```bash
flutter build apk --release
```
- [ ] Release APK created
- [ ] Can be distributed via Play Store or direct install

### iOS Build
```bash
flutter build ios --release
```
- [ ] Build completes
- [ ] Use Xcode for app signing and distribution

### Backend Deployment
Choose one platform:
- [ ] **AWS EC2**: Deploy with gunicorn/nginx
- [ ] **Google Cloud Run**: Docker deployment
- [ ] **Heroku**: Deploy using Procfile
- [ ] **Your Server**: Install and run with process manager

---

## 🐛 Troubleshooting

### Firebase Issues
- [ ] If "No project selected": Run `flutterfire configure --project=YOUR_PROJECT_ID`
- [ ] If "Permission denied" in Firestore: Check security rules in console
- [ ] If Google Sign-In fails: Ensure OAuth consent screen configured

### Backend Issues
- [ ] If "Port 8000 already in use": Change port in `server.py`
- [ ] If "Model not found": Verify `model.keras` and `words.pkl` exist
- [ ] If API returns 500: Check FastAPI logs for errors

### Flutter Issues
- [ ] If app crashes at startup: Run `flutter clean` then `flutter pub get`
- [ ] If camera not working: Grant camera permission in phone settings
- [ ] If can't connect to API: Check firewall and local network access

---

## ✅ Final Verification

Before considering setup complete:

- [ ] Firebase project created and configured
- [ ] Authentication working (Email + Google)
- [ ] Firestore database with security rules
- [ ] Flutter app runs without errors
- [ ] Backend API server responding
- [ ] Camera feature works
- [ ] Data saves to Firestore
- [ ] User statistics display correctly
- [ ] Dark mode functioning
- [ ] All screens accessible

---

## 📚 Documentation Files

- **SETUP_GUIDE.md** - General setup instructions
- **FIREBASE_SETUP.md** - Detailed Firebase configuration
- **README_COMPLETE.md** - Complete project documentation
- **IMPLEMENTATION_SUMMARY.md** - What was implemented

---

## 🎉 Congratulations!

If you've checked everything above, your Sign Language Translator app is ready to use!

Next steps:
- Share with testers
- Gather feedback
- Refine ML model with more data
- Deploy to production
- Monitor usage in Firebase Console

---

**Need help?** Check the documentation files or review the API docs at `http://localhost:8000/docs`
