# SetPause ⏱️💪

Minimalist gym rest timer built with Flutter.

SetPause helps you manage rest time between sets without unlocking your phone.  
The timer remains visible on the lock screen, allowing you to stay focused on your workout.

---

## ✨ Features

- ⏱️ 60-second rest timer
- 🔒 Lock screen notification (Spotify-style persistent notification)
- 🔔 Sound and vibration when rest time ends
- 🔁 Restart rest directly from notification
- 🏋️ Exercise tracking by workout type
- 🌙 Minimal dark UI
- ⚡ Fast and distraction-free

---

## 📱 Screenshots

*(add screenshots here later)*

Example:

| Timer | Lock screen notification |
|------|--------------------------|
| screenshot | screenshot |

---

## 🚀 Getting started

### Requirements

- Flutter 3+
- Android device or emulator

### Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/setpause.git
cd setpause
```

### Install dependencies
```bash
flutter pub get
```

### Run the app
```bash
flutter run
```

## 🔔 Notifications

SetPause uses persistent notifications to show the rest timer directly on the lock screen.

On Android 13+, the app will request notification permission on first launch.

Make sure notifications are enabled for the best experience.

## 🏗️ Project structure
```bash
lib/
 ├── features/
 │    ├── timer/
 │    └── exercises/
 │
 ├── services/
 │    ├── timer_service.dart
 │    └── notification_service.dart
 │
 └── app.dart
```
### Architecture principles
- Business logic separated from UI
- Singleton timer service
- Persistent notification state
- Minimal dependencies

## 🧠 Design philosophy

SetPause was designed with a focus on:

- Simplicity
- Speed
- Minimal interaction during workouts
- Lock screen usability
- Low cognitive load

No unnecessary features.
Just start your set and focus.

## 🛠️ Built with
- Flutter
- flutter_local_notifications

## 📦 Build APK
```bash
flutter build apk
```
Output:
```bash
build/app/outputs/flutter-apk/app-release.apk
```
