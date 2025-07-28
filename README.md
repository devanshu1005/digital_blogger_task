# 📱 Digital Blogger Task

A feature-rich Flutter application showcasing advanced video streaming, theme switching, and push notification handling. Built with best practices and modular architecture for scalability and clarity.

---

## 🚀 Features Overview

### 1. **Splash Screen**
- Automatically opens when the app launches.
- Animated introduction with branding and loading indicator.
- Navigates to the appropriate screen depending on:
  - Notification tap (if app was launched via a push notification).
  - Default navigation to home screen otherwise.

---

### 2. **Home Screen**
- Appears after the splash screen.
- Contains three primary interactive elements:
  
  ✅ **Notification Icon**  
  ➤ Navigates to the **Notification Demo Screen**.

  ✅ **Theme Toggle Icon**  
  ➤ Switch between **Light and Dark Mode** using `Provider`-based state management.

  ✅ **Start Streaming Button**  
  ➤ Navigates to the **Live Video Screen** with real-time video streaming capabilities.

---

### 3. **Live Video Screen**
- Displays a **scrollable list of HLS video streams** playing simultaneously.
- Tapping a video allows:
  - Fullscreen playback
  - Double-tap to **play/pause**
  - **Seek forward/backward** in fullscreen
  - **Speed control**, **quality adjustment**, and more.

---

### 4. **Custom Video Player**
- Uses `BetterPlayer` with:
  - Custom controls (`customControlsBuilder`)
  - Overlay enhancements
  - Seamless fullscreen toggling
  - Gesture interactions

---

### 5. **Notification Handling**
- Integrates `firebase_messaging` & `flutter_local_notifications` for:
  - FCM-based push notifications
  - Token management and topic subscription
- If a user taps a notification while the app is **terminated** or in **background**, they are navigated directly to `NotificationTestScreen`.

---

### 6. **Theme Management**
- Supports both **Light** and **Dark** modes.
- Managed using `Provider` via a centralized `ThemeProvider`.

---

### 7. **Global Styling**
- All theme colors are managed in `app_colors.dart`.
- Typography handled through `app_fonts.dart` for consistency and scalability.

---

## 🛠️ Tech Stack & Plugins

| Plugin | Purpose |
|--------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_messaging` | Push notifications |
| `flutter_local_notifications` | Local notification handling |
| `provider` | State management |
| `better_player` | Advanced video playback |
| `visibility_detector` | Optimize video playback by pausing off-screen videos |
| `shared_preferences` | Persistent storage for theme preferences |

---

## 📂 Project Structure

lib/
├── main.dart # Entry point
├── models/                     
│   └── video_model.dart          
├── themes/ # Theme colors and fonts
│ ├── app_colors.dart
│ └── app_fonts.dart
├── providers/ # State management
│ ├── theme_provider.dart
│ └── video_provider.dart
├── screens/
│ ├── splash_screen.dart
│ ├── home_screen.dart
│ ├── live_video_screen.dart
│ └── notification_screen.dart
├── services/
│ └── notification_service.dart
├── utils/widgets/
│ ├── video_player.dart # Video player widget with BetterPlayer
│ └── custom_video_controls.dart

---

## 🔔 Notifications

- Push notifications are manually triggered from Firebase Console.
- Based on the payload (`screen` field), users are deep-linked into:
  - `/notification-test`
  - `/video-stream`
  - `/home`

> **Example Notification Payload:**
```json
{
  "data": {
    "screen": "notification-test"
  }
}
