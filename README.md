# Logs Mobile App Frontend

This repository contains the Flutter frontend for the Logs app — a cross-platform personal journaling/mobile logging app.

## Getting Started

Follow these instructions to get your development environment set up quickly and start developing the app locally.

***

## Prerequisites

- **Flutter SDK**  
  Install Flutter SDK 3.x stable.  
  Follow official installation guide: https://flutter.dev/docs/get-started/install

- **Xcode (for iOS development)**  
  Latest Xcode version from Mac App Store (macOS only).

- **Android Studio (optional, for Android development)**  
  If you plan to build Android version later.

- **CocoaPods** (for iOS dependencies)  
  Install via Terminal:  
  ```bash
  sudo gem install cocoapods
  ```

***

## Setup

1. **Clone the repository**

```bash
git clone https://github.com/your-username/logs_frontend.git
cd logs_frontend
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

- For iOS simulator:

```bash
flutter run
```

- To specify the device (e.g., iPhone 16 Plus simulator):

```bash
flutter run -d 'iPhone 16 Plus'
```

***

## Code Formatting and Linting

- The project uses recommended Flutter lints.

- To check formatting (run locally before commits):

```bash
flutter format --set-exit-if-changed .
flutter analyze
```

- To format files automatically:

```bash
flutter format .
```

***

## Running Tests

Run unit and widget tests with coverage reporting:

```bash
flutter test --coverage
```

The coverage report is generated at `coverage/lcov.info`.

***

## Project Structure

- `lib/` — Flutter source code
  - `core/` — utilities, constants, themes
  - `features/` — feature-specific modules (logs, auth)
  - `shared/` — shared widgets, services, API clients
  - `main.dart` — app entry point

***

## Environment Variables and Configuration

- Currently, no explicit environment variable management.
- Backend API endpoints and keys are hardcoded or will be added in future iterations.
- Future plans: Add configuration files or Dart environment variables for backend URLs.

***

## Flutter CI/CD

- The project is integrated with GitHub Actions for CI:
  - Lint & format checks
  - Unit & widget tests
  - iOS simulator debug build on PRs
  - Coverage reports uploaded as artifacts

***

## Useful Commands

| Command                      | Description                        |
|------------------------------|----------------------------------|
| `flutter pub get`             | Install dependencies             |
| `flutter run`                 | Run app on connected device/simulator |
| `flutter test`                | Run all tests                   |
| `flutter format .`            | Auto-format code                |
| `flutter analyze`             | Run static analysis             |
| `flutter build ios --simulator --debug --no-codesign` | Build iOS debug simulator build |

***

## Contribution

- Please create feature branches from `development`.
- Open pull requests for all code changes.
- Ensure tests and lint checks pass before merging.
- Follow Dart & Flutter best practices.

***

## Troubleshooting

- Ensure Flutter SDK path is correctly set in your environment.
- For iOS builds: run `pod install` inside `ios/` folder if any dependency issues arise.
- Check the GitHub Actions workflow logs for CI issues.

***

Feel free to ask if you want me to help generate a full markdown README file or add sections like architecture overview, API guide, or contribution guidelines!