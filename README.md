# Recipe Box

A small Flutter app for keeping your own cookbook on your phone. You can browse
a list of recipes, filter them by meal type, open one to read its ingredients
and steps, and add, edit or delete your own — including a photo from your
gallery. Everything is stored locally in a SQLite database on the device, so the
app works fully offline and needs no backend or account.

The app ships with six sample recipes (Nasi Lemak, Pancakes, Chicken Rice, Fried
Rice, Spaghetti Bolognese, Chocolate Cake), seeded the first time the database is
created.

## Features

- **Recipe list** — all saved recipes, newest first, each showing its meal type.
- **Filter by type** — a dropdown to show only Breakfast, Lunch, Dinner or
  Dessert recipes (or all of them).
- **Recipe detail** — full-size photo, numbered cooking steps and a checklist of
  ingredients.
- **Add / edit** — a form with validation for the name, type, ingredients and
  steps. Ingredients and steps are entered one per line.
- **Photos** — pick an image from the device gallery via `image_picker`.
- **Delete** — with a confirmation dialog.

## Requirements

- **Flutter SDK 3.10.3** or newer (Dart SDK `>=3.0.3 <4.0.0`)
- Xcode (for iOS/macOS) or Android Studio + Android SDK (for Android)
- A connected device or running emulator/simulator

Check your setup with:

```bash
flutter doctor
```

### Supported platforms

Storage uses `sqflite`, which runs on **Android, iOS and macOS**. The
`web/`, `windows/` and `linux/` folders exist because they come with the Flutter
project template, but the app will not load recipes there without swapping in a
different SQLite backend.

## Getting started

### 1. Clone the repository

```bash
git clone https://github.com/farhanazman387/recipe_box.git
cd recipe_box
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

List the devices Flutter can see, then launch on one of them:

```bash
flutter devices
flutter run
```

To target a specific device, pass its id:

```bash
flutter run -d <device-id>
```

On first launch the app creates `recipe_box.db` in the app's database directory
and seeds it with the sample recipes. To start over from an empty-but-seeded
database, uninstall the app from the device (or clear its data) and run again.

### Building a release

```bash
flutter build apk       # Android
flutter build ios       # iOS (requires signing setup in Xcode)
```

## Project structure

The app follows an MVVM layering, with `provider` supplying the view model to the
widget tree.

```
lib/
├── main.dart                        # Wires up services, repository and view model
├── models/
│   ├── recipe.dart                  # Recipe entity
│   └── recipe_type.dart             # Meal type entity (JSON-backed)
├── services/
│   ├── database_services.dart       # SQLite setup, schema and sample-data seeding
│   └── recipe_type_service.dart     # Loads meal types from the bundled asset
├── repositories/
│   └── recipe_repository.dart       # CRUD over the recipes table
├── viewmodels/
│   └── recipe_view_model.dart       # App state: loading, errors, filtering
└── views/
    ├── recipe_list_page.dart        # Home screen with the type filter
    ├── recipe_detail_page.dart      # Single recipe, with edit/delete
    └── recipe_form_page.dart        # Add and edit form
assets/
└── recipetypes.json                 # The four meal types
```

### Data model

Recipes live in a single `recipes` table:

| Column           | Type    | Notes                                  |
| ---------------- | ------- | -------------------------------------- |
| `id`             | INTEGER | Primary key, autoincrement             |
| `title`          | TEXT    | Recipe name                            |
| `recipe_type_id` | INTEGER | Refers to an id in `recipetypes.json`  |
| `image_path`     | TEXT    | File path of the picked photo, nullable |
| `ingredients`    | TEXT    | JSON-encoded list of strings           |
| `steps`          | TEXT    | JSON-encoded list of strings           |

Meal types are not stored in the database — they are read from the bundled
`assets/recipetypes.json` asset at startup. To add a new type, add an entry there.

## Dependencies

| Package         | Used for                                     |
| --------------- | -------------------------------------------- |
| `sqflite`       | Local SQLite storage                         |
| `path`          | Building the database file path              |
| `provider`      | Providing `RecipeViewModel` to the widgets   |
| `image_picker`  | Choosing a recipe photo from the gallery     |
| `cupertino_icons` | iOS-style icons                            |

## Tests

```bash
flutter test
```

Note: `test/widget_test.dart` is still the counter smoke test from the Flutter
project template and does not match this app, so it currently fails. Replacing it
with real tests is an open task.
