class Manhwa {
  final int id;
  final String name;
  final String synopsis;
  final int yearReleased;
  final String chapters;
  final int chapterMin;
  final int? chapterMax;
  final String imageUrl;
  final String status;
  final String rating;
  final List<String> genres;
  final List<String> categories;
  final int currentChapter;
  final String readingStatus;

  Manhwa({
    required this.id,
    required this.name,
    required this.synopsis,
    required this.yearReleased,
    required this.chapters,
    required this.chapterMin,
    this.chapterMax,
    required this.imageUrl,
    required this.status,
    required this.rating,
    required this.genres,
    required this.categories,
    required this.currentChapter,
    required this.readingStatus,
  });

  factory Manhwa.fromJson(Map<String, dynamic> json) {
    final data = json['manhwa'];

    return Manhwa(
      id: data['id'],
      name: data['name'],
      synopsis: data['synopsis'],
      yearReleased: data['year_released'],
      chapters: data['chapters'],
      chapterMin: data['chapter_min'],
      chapterMax: data['chapter_max'], // nullable
      imageUrl: data['image_url'],
      status: data['status'],
      rating: data['rating'],
      genres: List<String>.from(data['genres']),
      categories: List<String>.from(data['categories']),
      currentChapter: json['current_chapter'],
      readingStatus: json['reading_status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'current_chapter': currentChapter,
    'reading_status': readingStatus,
    'manhwa': {
      'id': id,
      'name': name,
      'synopsis': synopsis,
      'year_released': yearReleased,
      'chapters': chapters,
      'chapter_min': chapterMin,
      'chapter_max': chapterMax,
      'image_url': imageUrl,
      'status': status,
      'rating': rating,
      'genres': genres,
      'categories': categories,
    },
  };
}
