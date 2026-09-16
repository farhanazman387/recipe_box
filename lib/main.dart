import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/recipe_repository.dart';
import 'services/database_services.dart';
import 'services/recipe_type_service.dart';
import 'viewmodels/recipe_view_model.dart';
import 'views/recipe_list_page.dart';

void main() {
  final databaseService = DatabaseService();
  final recipeRepository = RecipeRepository(databaseService);
  final recipeTypeService = RecipeTypeService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeViewModel(
        recipeRepository: recipeRepository,
        recipeTypeService: recipeTypeService,
      )..loadData(),
      child: const RecipeBox(),
    ),
  );
}

class RecipeBox extends StatelessWidget {
  const RecipeBox({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Box',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const RecipeListPage(),
    );
  }
}
