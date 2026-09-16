class RecipeType {
  final int id;
  final String name;

  const RecipeType({
    required this.id,
    required this.name,
  });

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
