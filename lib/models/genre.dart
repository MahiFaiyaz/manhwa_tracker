class Genre {
  final String name;
  final String description;

  Genre({required this.name, required this.description});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(name: json['name'], description: json['description']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
