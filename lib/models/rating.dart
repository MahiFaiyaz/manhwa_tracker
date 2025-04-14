class Rating {
  final String name;
  final String description;

  Rating({required this.name, required this.description});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(name: json['name'], description: json['description']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
