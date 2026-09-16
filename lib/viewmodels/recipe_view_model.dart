import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../models/recipe_type.dart';
import '../repositories/recipe_repository.dart';
import '../services/recipe_type_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final RecipeTypeService _recipeTypeService;

  RecipeViewModel({
    required RecipeRepository recipeRepository,
    required RecipeTypeService recipeTypeService,
  })  : _recipeRepository = recipeRepository,
        _recipeTypeService = recipeTypeService;

  List<Recipe> _recipes = [];
  List<RecipeType> _recipeTypes = [];

  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedRecipeTypeId;

  List<Recipe> get recipes {
    if (_selectedRecipeTypeId == null) {
      return _recipes;
    } else {
      return _recipes
          .where((recipe) => recipe.recipeTypeId == _selectedRecipeTypeId)
          .toList();
    }
  }

  List<RecipeType> get recipeTypes => _recipeTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedRecipeTypeId => _selectedRecipeTypeId;

  void filterByRecipeType(int? recipeTypeId) {
    _selectedRecipeTypeId = recipeTypeId;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _recipeRepository.getRecipes();
      _recipeTypes = await _recipeTypeService.loadRecipeTypes();
    } catch (error) {
      _errorMessage = 'Failed to load recipes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipeRepository.insertRecipe(recipe);
    await loadData();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeRepository.updateRecipe(recipe);
    await loadData();
  }

  Future<void> deleteRecipe(int id) async {
    await _recipeRepository.deleteRecipe(id);
    await loadData();
  }

  Future<List<RecipeType>> loadRecipeTypes() {
    return _recipeTypeService.loadRecipeTypes();
  }
}
