import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../models/recipe.dart';
import '../viewmodels/recipe_view_model.dart';
import 'recipe_form_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final recipeType = context.read<RecipeViewModel>().recipeTypes.firstWhere(
          (type) => type.id == recipe.recipeTypeId,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormPage(
                    recipe: recipe,
                  ),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            recipe.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            recipeType.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (recipe.imagePath != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(recipe.imagePath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...recipe.ingredients.map(
            (ingredient) => ListTile(
              leading: const Icon(Icons.check),
              title: Text(ingredient),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Steps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map(
                (entry) => ListTile(
                  leading: CircleAvatar(
                    child: Text('${entry.key + 1}'),
                  ),
                  title: Text(entry.value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final viewModel = context.read<RecipeViewModel>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text(
            'Are you sure you want to delete "${recipe.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || recipe.id == null) {
      return;
    }

    await viewModel.deleteRecipe(recipe.id!);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
