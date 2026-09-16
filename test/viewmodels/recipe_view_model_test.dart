import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_box/models/recipe.dart';
import 'package:recipe_box/models/recipe_type.dart';
import 'package:recipe_box/repositories/recipe_repository.dart';
import 'package:recipe_box/services/recipe_type_service.dart';
import 'package:recipe_box/viewmodels/recipe_view_model.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockRecipeTypeService extends Mock implements RecipeTypeService {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockRecipeTypeService mockRecipeTypeService;
  late RecipeViewModel viewModel;

  const breakfast = RecipeType(
    id: 1,
    name: 'Breakfast',
  );

  const lunch = RecipeType(
    id: 2,
    name: 'Lunch',
  );

  const pancakes = Recipe(
    id: 1,
    title: 'Pancakes',
    recipeTypeId: 1,
    imagePath: null,
    ingredients: ['Flour', 'Milk', 'Eggs'],
    steps: ['Mix ingredients', 'Cook in pan'],
  );

  const chickenRice = Recipe(
    id: 2,
    title: 'Chicken Rice',
    recipeTypeId: 2,
    imagePath: null,
    ingredients: ['Rice', 'Chicken'],
    steps: ['Cook rice', 'Cook chicken'],
  );

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockRecipeTypeService = MockRecipeTypeService();

    viewModel = RecipeViewModel(
      recipeRepository: mockRecipeRepository,
      recipeTypeService: mockRecipeTypeService,
    );
  });

  group('RecipeViewModel', () {
    test('loadData loads recipes and recipe types', () async {
      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [pancakes, chickenRice],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast, lunch],
      );

      await viewModel.loadData();

      expect(viewModel.recipes, [pancakes, chickenRice]);
      expect(viewModel.recipeTypes, [breakfast, lunch]);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });

    test('filterByRecipeType filters recipes by type', () async {
      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [pancakes, chickenRice],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast, lunch],
      );

      await viewModel.loadData();

      viewModel.filterByRecipeType(1);

      expect(viewModel.recipes, [pancakes]);
      expect(viewModel.selectedRecipeTypeId, 1);
    });

    test('filterByRecipeType with null shows all recipes', () async {
      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [pancakes, chickenRice],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast, lunch],
      );

      await viewModel.loadData();

      viewModel.filterByRecipeType(1);
      viewModel.filterByRecipeType(null);

      expect(viewModel.recipes, [pancakes, chickenRice]);
      expect(viewModel.selectedRecipeTypeId, isNull);
    });

    test('addRecipe inserts recipe and reloads data', () async {
      when(
        () => mockRecipeRepository.insertRecipe(pancakes),
      ).thenAnswer(
        (_) async => 1,
      );

      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [pancakes],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast],
      );

      await viewModel.addRecipe(pancakes);

      verify(
        () => mockRecipeRepository.insertRecipe(pancakes),
      ).called(1);

      expect(viewModel.recipes, [pancakes]);
    });

    test('updateRecipe updates recipe and reloads data', () async {
      when(
        () => mockRecipeRepository.updateRecipe(pancakes),
      ).thenAnswer(
        (_) async => 1,
      );

      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [pancakes],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast],
      );

      await viewModel.updateRecipe(pancakes);

      verify(
        () => mockRecipeRepository.updateRecipe(pancakes),
      ).called(1);

      expect(viewModel.recipes, [pancakes]);
    });

    test('deleteRecipe deletes recipe and reloads data', () async {
      when(
        () => mockRecipeRepository.deleteRecipe(1),
      ).thenAnswer(
        (_) async => 1,
      );

      when(
        () => mockRecipeRepository.getRecipes(),
      ).thenAnswer(
        (_) async => [],
      );

      when(
        () => mockRecipeTypeService.loadRecipeTypes(),
      ).thenAnswer(
        (_) async => [breakfast],
      );

      await viewModel.deleteRecipe(1);

      verify(
        () => mockRecipeRepository.deleteRecipe(1),
      ).called(1);

      expect(viewModel.recipes, isEmpty);
    });
  });
}
