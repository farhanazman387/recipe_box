import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/recipe_type.dart';

class RecipeTypeService {
  Future<List<RecipeType>> loadRecipeTypes() async {
    final jsonString = await rootBundle.loadString(
      'assets/recipetypes.json',
    );

    final List<dynamic> jsonList = jsonDecode(jsonString);

    return jsonList
        .map(
          (json) => RecipeType.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
