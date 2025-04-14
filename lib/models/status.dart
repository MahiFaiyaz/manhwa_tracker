class Status {
  final String name;
  final String description;

  Status({required this.name, required this.description});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(name: json['name'], description: json['description']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}
