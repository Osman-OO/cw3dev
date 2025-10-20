# Task Manager App

A Flutter task management application with CRUD operations, priority system, local persistence, and light/dark theme support.

## Features

- Add, complete, and delete tasks
- Priority levels (Low, Medium, High) with color coding
- Automatic task sorting by priority
- Light and Dark mode toggle
- Local persistence using SharedPreferences
- Clean and intuitive UI with Material Design 3

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio or Xcode for emulator

### Installation

1. Clone the repository
2. Navigate to project directory
3. Run `flutter pub get`
4. Run `flutter run`

## Project Structure

- `lib/main.dart` - Main application code with all widgets and logic
- `test/widget_test.dart` - Widget tests
- `pubspec.yaml` - Project dependencies

## Dependencies

- `shared_preferences: ^2.2.2` - Local data persistence

## Usage

1. Enter task name in the text field
2. Select priority level from dropdown
3. Tap "Add Task" button
4. Check checkbox to mark task complete
5. Change priority by tapping priority dropdown in task
6. Delete task with delete button
7. Toggle theme with button in AppBar

## Testing

Run tests with:
```bash
flutter test
```

## Building APK

Generate APK with:
```bash
flutter build apk --release
```

## Commit History

This project maintains regular commits throughout development for grading purposes.
