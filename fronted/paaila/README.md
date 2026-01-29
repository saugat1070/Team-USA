# Paaila - Flutter Mobile App

A Flutter-based mobile application for tracking walks, runs, and territory conquests with real-time location tracking, social features, and gamification elements.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the App](#running-the-app)
- [Build for Production](#build-for-production)
- [Configuration](#configuration)

## ✨ Features

- **User Authentication** - Login and signup with JWT-based authentication
- **Real-time Location Tracking** - Track walks and runs with GPS
- **Interactive Maps** - Google Maps and Flutter Map integration
- **Territory Conquest** - Gamified territory claiming system
- **Activity Tracking** - Monitor running/walking activities
- **Rankings & Rewards** - Leaderboards and reward system
- **Real-time Updates** - Socket.IO integration for live data

## 🛠 Tech Stack

- **Framework:** Flutter (Dart SDK ^3.10.7)
- **State Management:** Flutter Riverpod
- **Maps:** Google Maps Flutter, Flutter Map
- **Location:** Geolocator, Geocoding
- **Networking:** HTTP, Socket.IO Client
- **Storage:** Shared Preferences

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── core/                     # Core utilities and constants
│   └── constants/
│       ├── app_colors.dart   # App color definitions
│       └── app_constants.dart # App-wide constants
├── models/                   # Data models
│   ├── auth_request_models.dart
│   ├── auth_response_models.dart
│   ├── popular_route.dart
│   ├── reward.dart
│   ├── run.dart
│   ├── trail_model.dart
│   └── user_model.dart
├── pages/                    # Main page views
│   ├── activity_page.dart
│   ├── profile_page.dart
│   └── ranking_page.dart
├── providers/                # Riverpod state providers
│   ├── auth_provider.dart    # Authentication state
│   ├── bottom_nav_provider.dart
│   ├── location_provider.dart
│   ├── socket_provider.dart
│   └── trail_provider.dart
├── repositories/             # Data repositories
│   └── run_repository.dart
├── screens/                  # Screen implementations
│   ├── activity/             # Activity tracking screens
│   ├── auth/                 # Authentication screens
│   │   ├── login_screen.dart
│   │   └── sign_up.dart
│   ├── home/                 # Home screens
│   │   └── home_page.dart
│   ├── map/                  # Map-related screens
│   │   ├── map_for_running.dart
│   │   ├── map_page.dart
│   │   ├── run_tracker.dart
│   │   └── trail_map_page.dart
│   ├── profile/              # User profile screens
│   ├── rewards/              # Rewards screens
│   ├── routes/               # Route screens
│   ├── run/                  # Run tracking screens
│   └── splash/               # Splash screens
├── services/                 # Business logic services
│   ├── auth_service.dart     # Authentication service
│   ├── data_socket_service.dart
│   ├── location_api_service.dart
│   ├── location_service.dart
│   ├── ranking_service.dart
│   ├── reward_service.dart
│   ├── socket_service.dart
│   ├── territory_conquest_service.dart
│   └── trail_service.dart
└── widgets/                  # Reusable UI components
    ├── app_bar.dart
    ├── app_header.dart
    ├── auth_guard.dart       # Route protection widget
    ├── bottom_nav_bar.dart
    ├── custom_button.dart
    ├── stat_card.dart
    └── territory_tile.dart

assets/
├── data/                     # Static data files
│   ├── district.json
│   ├── dummy_trails.json
│   └── trails.json
└── images/                   # Image assets
```

## 📦 Prerequisites

Before running the app, ensure you have the following installed:

1. **Flutter SDK** (version 3.10.7 or higher)

   ```bash
   flutter --version
   ```

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **VS Code** with Flutter extensions

4. **Android SDK** (for Android development)
   - Minimum SDK: 21 (Android 5.0)
   - Target SDK: Latest stable

5. **Xcode** (for iOS development - macOS only)

6. **Git** for version control

## 🚀 Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd Team-USA/fronted/paaila
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up Google Maps API Key** (for Android)
   - Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_API_KEY"/>
     ```

4. **Set up Google Maps API Key** (for iOS)
   - Add to `ios/Runner/AppDelegate.swift`:
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```

## ▶️ Running the App

### Check Connected Devices

```bash
flutter devices
```

### Run in Debug Mode

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run on Android emulator
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run on Chrome (web)
flutter run -d chrome
```

### Run with Hot Reload

The app supports hot reload by default. Press `r` in the terminal to hot reload, or `R` for hot restart.

### Run with Verbose Logging

```bash
flutter run --verbose
```

## 🏗 Build for Production

### Android APK

```bash
# Build release APK
flutter build apk --release

# Build APK for specific architecture
flutter build apk --split-per-abi
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

Output: `build/web/`

## ⚙️ Configuration

### Environment Configuration

Update the backend API URL in the services:

- Check `lib/core/constants/app_constants.dart` for API base URLs
- Update socket connection URLs in `lib/services/socket_service.dart`

### App Icon Generation

```bash
flutter pub run flutter_launcher_icons
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/widget_test.dart
```

## 📱 App Routes

| Route         | Screen                 | Protected |
| ------------- | ---------------------- | --------- |
| `/`           | Animated Splash Screen | No        |
| `/onboarding` | Onboarding/Splash      | No        |
| `/login`      | Login Screen           | No        |
| `/signup`     | Sign Up Screen         | No        |
| `/home`       | Home Page              | Yes       |
| `/map`        | Map Page               | Yes       |
| `/activity`   | Activity Page          | Yes       |
| `/profile`    | User Profile           | Yes       |

## 🔧 Troubleshooting

### Common Issues

1. **Gradle build fails**

   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **iOS pod install fails**

   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

3. **Location permission issues**
   - Ensure location permissions are added in AndroidManifest.xml and Info.plist
   - Check device location services are enabled

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)
