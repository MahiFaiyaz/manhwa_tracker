class Category {
  final String name;
  final String description;

  Category({required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'], description: json['description']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
