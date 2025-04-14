class ManhwaFilter {
  final List<String> genres;
  final List<String> categories;
  final List<String> status;
  final List<String> ratings;
  final int minChapters;
  final int maxChapters;
  final int minYearReleased;
  final int maxYearReleased;

  ManhwaFilter({
    this.genres = const [],
    this.categories = const [],
    this.status = const [],
    this.ratings = const [],
    this.minChapters = 0,
    this.maxChapters = 0,
    this.minYearReleased = 0,
    this.maxYearReleased = 0,
  });

  Map<String, dynamic> toJson() => {
    "genres": genres,
    "categories": categories,
    "status": status,
    "ratings": ratings,
    "min_chapters": minChapters,
    "max_chapters": maxChapters,
    "min_year_released": minYearReleased,
    "max_year_released": maxYearReleased,
  };
}
