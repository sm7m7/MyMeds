# MyMeds 💊

**Informational medication-management mobile app** built with Flutter.

> ⚠️ **Disclaimer**: This app is for informational purposes only. It is NOT a diagnostic tool. Every medical screen displays the disclaimer: _"Informational only. Consult a healthcare professional."_

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.47+)
- [Firebase CLI](https://firebase.google.com/docs/cli) & [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- Android Studio / Xcode (for mobile targets)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd my_meds
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`. Replace the placeholder file at
   `lib/core/config/firebase_options_placeholder.dart`.

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Fill in your Firebase keys and other secrets in `.env`.
   Alternatively, use `--dart-define` flags at build time:
   ```bash
   flutter run --dart-define=FIREBASE_API_KEY=xxx
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Folder Structure

```
lib/
├── main.dart                        # Entry point — Firebase init + ProviderScope
├── app.dart                         # MaterialApp.router setup
├── core/
│   ├── config/
│   │   ├── env_config.dart          # .env / --dart-define loader
│   │   └── firebase_options_placeholder.dart
│   ├── constants/
│   │   └── constants.dart           # App-wide constants & disclaimer
│   ├── router/
│   │   └── router.dart              # GoRouter + ShellRoute navigation
│   ├── theme/
│   │   └── theme.dart               # Material 3 light & dark themes
│   └── widgets/
│       ├── bottom_nav_shell.dart     # 5-tab bottom navigation scaffold
│       └── medical_disclaimer.dart   # Reusable disclaimer widget
├── features/
│   ├── cabinet/
│   │   ├── data/                    # Repositories, data sources
│   │   ├── domain/                  # Models, entities
│   │   └── presentation/           # Screens, widgets, providers
│   │       └── cabinet_screen.dart
│   ├── search/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── search_screen.dart
│   ├── reminders/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── reminders_screen.dart
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── dashboard_screen.dart
│   └── more/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── more_screen.dart
└── l10n/
    ├── app_en.arb                   # English strings
    ├── app_fr.arb                   # French strings
    └── app_ar.arb                   # Arabic strings (RTL)
```

---

## 🏗 Architecture

| Layer | Description |
|---|---|
| **Feature-first** | Each feature has `data/`, `domain/`, `presentation/` folders |
| **State management** | [Riverpod](https://riverpod.dev/) |
| **Navigation** | [go_router](https://pub.dev/packages/go_router) with `ShellRoute` |
| **Backend** | Firebase (Auth, Firestore, Cloud Messaging) |
| **Localization** | `flutter_localizations` + ARB files (en, fr, ar with RTL) |
| **Secrets** | `.env` via `flutter_dotenv` / `--dart-define` — never hardcoded |

---

## 🌍 Localization

Supported locales: **English (en)**, **French (fr)**, **Arabic (ar)**.

Arabic includes full RTL support. The app automatically sets text direction based on locale.

To add a new locale:
1. Create `lib/l10n/app_<locale>.arb`
2. Add the locale to `supportedLocales` in `app.dart`
3. Run `flutter gen-l10n`

---

## ⚕️ Medical Disclaimer Rule

> **Every screen that displays medical or medication information MUST include the `MedicalDisclaimer` widget.**
>
> The disclaimer reads: _"Informational only. Consult a healthcare professional."_
>
> Use it like this:
> ```dart
> import 'package:my_meds/core/widgets/medical_disclaimer.dart';
>
> // Inside your build method:
> const MedicalDisclaimer(),
> ```

---

## 📜 License

This project is private and not published to pub.dev.
