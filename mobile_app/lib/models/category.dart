class Category {
  final int categoryId;
  final String categoryName;
  final String? description;
  final String? image;

  Category({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.parse(json['category_id'].toString()),
      categoryName: json['category_name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'image': image,
    };
  }
}
