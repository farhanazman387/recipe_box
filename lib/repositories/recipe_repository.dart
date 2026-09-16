import 'dart:convert';

import '../models/recipe.dart';
import '../services/database_services.dart';

class RecipeRepository {
  final DatabaseService _databaseService;

  RecipeRepository(this._databaseService);

  Future<List<Recipe>> getRecipes() async {
    final database = await _databaseService.database;

    final rows = await database.query(
      DatabaseService.recipesTable,
      orderBy: 'id DESC',
    );

    return rows.map(_mapToRecipe).toList();
  }

  Future<Recipe?> getRecipeById(int id) async {
    final database = await _databaseService.database;

    final rows = await database.query(
      DatabaseService.recipesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapToRecipe(rows.first);
  }

  Future<int> insertRecipe(Recipe recipe) async {
    final database = await _databaseService.database;

    return database.insert(
      DatabaseService.recipesTable,
      _mapToDatabase(recipe),
    );
  }

  Future<int> updateRecipe(Recipe recipe) async {
    if (recipe.id == null) {
      throw ArgumentError('Recipe ID is required for update.');
    }

    final database = await _databaseService.database;

    return database.update(
      DatabaseService.recipesTable,
      _mapToDatabase(recipe),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final database = await _databaseService.database;

    return database.delete(
      DatabaseService.recipesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _mapToDatabase(Recipe recipe) {
    return {
      'title': recipe.title,
      'recipe_type_id': recipe.recipeTypeId,
      'image_path': recipe.imagePath,
      'ingredients': jsonEncode(recipe.ingredients),
      'steps': jsonEncode(recipe.steps),
    };
  }

  Recipe _mapToRecipe(Map<String, dynamic> row) {
    return Recipe(
      id: row['id'] as int,
      title: row['title'] as String,
      recipeTypeId: row['recipe_type_id'] as int,
      imagePath: row['image_path'] as String?,
      ingredients: List<String>.from(
        jsonDecode(row['ingredients'] as String),
      ),
      steps: List<String>.from(
        jsonDecode(row['steps'] as String),
      ),
    );
  }
}
