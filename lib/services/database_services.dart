import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static const String _databaseName = 'recipe_box.db';
  static const int _databaseVersion = 1;

  static const String recipesTable = 'recipes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $recipesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        recipe_type_id INTEGER NOT NULL,
        image_path TEXT,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL
      )
    ''');

    await _seedRecipes(database);
  }

  Future<void> _seedRecipes(Database database) async {
    final recipes = [
      {
        'title': 'Nasi Lemak',
        'recipe_type_id': 1,
        'image_path': null,
        'ingredients': jsonEncode([
          '2 cups rice',
          '1 cup coconut milk',
          '2 eggs',
          'Sambal',
          'Cucumber',
          'Peanuts',
        ]),
        'steps': jsonEncode([
          'Cook the rice with coconut milk.',
          'Boil the eggs.',
          'Prepare the sambal.',
          'Serve with cucumber and peanuts.',
        ]),
      },
      {
        'title': 'Pancakes',
        'recipe_type_id': 1,
        'image_path': null,
        'ingredients': jsonEncode([
          '1 cup flour',
          '1 cup milk',
          '1 egg',
          '1 tablespoon sugar',
        ]),
        'steps': jsonEncode([
          'Mix all ingredients in a bowl.',
          'Heat a pan.',
          'Pour the batter into the pan.',
          'Cook both sides until golden brown.',
        ]),
      },
      {
        'title': 'Chicken Rice',
        'recipe_type_id': 2,
        'image_path': null,
        'ingredients': jsonEncode([
          'Chicken',
          'Rice',
          'Ginger',
          'Garlic',
          'Soy sauce',
        ]),
        'steps': jsonEncode([
          'Prepare and cook the chicken.',
          'Cook the rice with ginger and garlic.',
          'Slice the chicken.',
          'Serve the chicken with rice and sauce.',
        ]),
      },
      {
        'title': 'Fried Rice',
        'recipe_type_id': 2,
        'image_path': null,
        'ingredients': jsonEncode([
          'Cooked rice',
          'Egg',
          'Carrot',
          'Peas',
          'Soy sauce',
        ]),
        'steps': jsonEncode([
          'Heat a pan.',
          'Cook the egg and vegetables.',
          'Add the rice.',
          'Add soy sauce and stir-fry.',
        ]),
      },
      {
        'title': 'Spaghetti Bolognese',
        'recipe_type_id': 3,
        'image_path': null,
        'ingredients': jsonEncode([
          'Spaghetti',
          'Minced beef',
          'Tomato sauce',
          'Onion',
          'Garlic',
        ]),
        'steps': jsonEncode([
          'Cook the spaghetti.',
          'Fry the onion and garlic.',
          'Add minced beef.',
          'Add tomato sauce and simmer.',
          'Serve the sauce with spaghetti.',
        ]),
      },
      {
        'title': 'Chocolate Cake',
        'recipe_type_id': 4,
        'image_path': null,
        'ingredients': jsonEncode([
          'Flour',
          'Cocoa powder',
          'Sugar',
          'Eggs',
          'Milk',
        ]),
        'steps': jsonEncode([
          'Mix the dry ingredients.',
          'Add the eggs and milk.',
          'Pour the mixture into a cake pan.',
          'Bake until fully cooked.',
        ]),
      },
    ];

    for (final recipe in recipes) {
      await database.insert(
        recipesTable,
        recipe,
      );
    }
  }
}
