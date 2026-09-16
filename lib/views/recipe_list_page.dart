import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/recipe_view_model.dart';
import 'recipe_form_page.dart';
import 'recipe_detail_page.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(RecipeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(viewModel.errorMessage!),
      );
    }

    if (viewModel.recipes.isEmpty) {
      return const Center(
        child: Text('No recipes available.'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<int?>(
            value: viewModel.selectedRecipeTypeId,
            decoration: const InputDecoration(
              labelText: 'Recipe Type',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Recipes'),
              ),
              ...viewModel.recipeTypes.map(
                (type) => DropdownMenuItem<int?>(
                  value: type.id,
                  child: Text(type.name),
                ),
              ),
            ],
            onChanged: viewModel.filterByRecipeType,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.recipes.length,
            itemBuilder: (context, index) {
              final recipe = viewModel.recipes[index];

              final recipeType = viewModel.recipeTypes.firstWhere(
                (type) => type.id == recipe.recipeTypeId,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(recipe.title),
                  subtitle: Text(recipeType.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
