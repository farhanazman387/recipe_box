import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../models/recipe_type.dart';
import '../viewmodels/recipe_view_model.dart';

class RecipeFormPage extends StatefulWidget {
  final Recipe? recipe;

  const RecipeFormPage({
    super.key,
    this.recipe,
  });

  bool get isEditing => recipe != null;

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();

  int? _selectedRecipeTypeId;
  String? _imagePath;
  late Future<List<RecipeType>> _recipeTypesFuture;

  @override
  void initState() {
    super.initState();

    _recipeTypesFuture = context.read<RecipeViewModel>().loadRecipeTypes();

    final recipe = widget.recipe;

    if (recipe != null) {
      _titleController.text = recipe.title;
      _selectedRecipeTypeId = recipe.recipeTypeId;
      _imagePath = recipe.imagePath;
      _ingredientsController.text = recipe.ingredients.join('\n');
      _stepsController.text = recipe.steps.join('\n');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRecipeTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipe type.'),
        ),
      );
      return;
    }

    final ingredients = _ingredientsController.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final steps = _stepsController.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.recipe?.id,
      title: _titleController.text.trim(),
      recipeTypeId: _selectedRecipeTypeId!,
      imagePath: _imagePath,
      ingredients: ingredients,
      steps: steps,
    );

    final viewModel = context.read<RecipeViewModel>();

    if (widget.isEditing) {
      await viewModel.updateRecipe(recipe);
    } else {
      await viewModel.addRecipe(recipe);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Recipe' : 'Add Recipe',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a recipe name.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<RecipeType>>(
              future: _recipeTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Unable to load recipe types.',
                  );
                }

                final recipeTypes = snapshot.data ?? [];

                return DropdownButtonFormField<int>(
                  value: _selectedRecipeTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Type',
                    border: OutlineInputBorder(),
                  ),
                  items: recipeTypes
                      .map(
                        (type) => DropdownMenuItem<int>(
                          value: type.id,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRecipeTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a recipe type.';
                    }

                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Choose Picture'),
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              Image.file(
                File(_imagePath!),
                height: 200,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Ingredients',
                hintText: 'Enter one ingredient per line',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter ingredients.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stepsController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Steps',
                hintText: 'Enter one step per line',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the recipe steps.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveRecipe,
              child: Text(
                widget.isEditing ? 'Update Recipe' : 'Save Recipe',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
