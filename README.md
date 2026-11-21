# Expense Tracker (Flutter + SQLite)

A simple local expense tracker based on the supplied assignment.

## Features
- Home screen titled **Expense Tracker**
- Displays the sum of all saved expenses
- Displays saved expenses in a scrolling list
- Floating action button opens the Add Expense form
- Delete each expense using its trailing delete IconButton (with confirmation)
- Validates that title and amount are not empty
- Amount uses a decimal numeric keyboard and must be greater than zero
- Saves data locally in SQLite
- Returns to the home screen after a successful save and refreshes the list/total

## SQLite schema

```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL CHECK(amount > 0)
);
```

## Run the project

1. Install Flutter SDK and Android Studio.
2. Extract this project.
3. Open a terminal in the `expense_tracker` directory.
4. Run:

```bash
flutter create . --platforms=android,ios
flutter pub get
flutter run
```

If Flutter asks whether to overwrite existing files during `flutter create`, keep the existing `lib/` and `pubspec.yaml` files. The command creates the native platform folders.
