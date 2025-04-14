class ManhwaFilter {
  final List<String>? genres;
  final List<String>? categories;
  final List<String>? status;
  final List<String>? ratings;
  final int? minChapters;
  final int? maxChapters;
  final int? minYearReleased;
  final int? maxYearReleased;

  ManhwaFilter({
    this.genres,
    this.categories,
    this.status,
    this.ratings,
    this.minChapters,
    this.maxChapters,
    this.minYearReleased,
    this.maxYearReleased,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (genres != null && genres!.isNotEmpty) {
      json['genres'] = genres;
    }
    if (categories != null && categories!.isNotEmpty) {
      json['categories'] = categories;
    }
    if (status != null && status!.isNotEmpty) {
      json['status'] = status;
    }
    if (ratings != null && ratings!.isNotEmpty) {
      json['ratings'] = ratings;
    }
    if (minChapters != null && minChapters! > 0) {
      json['min_chapters'] = minChapters;
    }
    if (maxChapters != null && maxChapters! > 0) {
      json['max_chapters'] = maxChapters;
    }
    if (minYearReleased != null && minYearReleased! > 0) {
      json['min_year_released'] = minYearReleased;
    }
    if (maxYearReleased != null && maxYearReleased! > 0) {
      json['max_year_released'] = maxYearReleased;
    }

    return json;
  }
}
