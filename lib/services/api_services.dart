import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/widgets.dart';

Future<List<Map<String, dynamic>>> loadMockData(String filename) async {
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

  final String jsonString = await rootBundle.loadString(
    'lib/sample_data/$filename.json',
  );
  final List<dynamic> jsonData = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(jsonData);
}

Future<List<Genre>> fetchGenres({void Function(String)? onFallback}) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/genres'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Genre.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch genres: status ${response.statusCode}');
    }
  } catch (e) {
    foundation.debugPrint("Genre API failed: $e — falling back to mock data.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFallback?.call("Genres loaded using fallback data");
    });

    final mockData = await loadMockData('genres');
    return mockData.map((json) => Genre.fromJson(json)).toList();
  }
}

Future<List<Category>> fetchCategories({
  void Function(String)? onFallback,
}) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch categories: status ${response.statusCode}',
      );
    }
  } catch (e) {
    foundation.debugPrint(
      "Category API failed: $e — falling back to mock data.",
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFallback?.call("Categories loaded using fallback data");
    });

    final mockData = await loadMockData('categories');
    return mockData.map((json) => Category.fromJson(json)).toList();
  }
}

Future<List<Status>> fetchStatus({void Function(String)? onFallback}) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/statuses'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Status.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch status: status ${response.statusCode}');
    }
  } catch (e) {
    foundation.debugPrint("Status API failed: $e — falling back to mock data.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFallback?.call("Statuses loaded using fallback data");
    });

    final mockData = await loadMockData('status');
    return mockData.map((json) => Status.fromJson(json)).toList();
  }
}

Future<List<Rating>> fetchRatings({void Function(String)? onFallback}) async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/ratings'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch ratings: status ${response.statusCode}');
    }
  } catch (e) {
    foundation.debugPrint("Rating API failed: $e — falling back to mock data.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFallback?.call("Ratings loaded using fallback data");
    });

    final mockData = await loadMockData('ratings');
    return mockData.map((json) => Rating.fromJson(json)).toList();
  }
}

Future<List<Manhwa>> fetchManhwas() async {
  final data = await loadMockData('manhwas');
  return data.map((json) => Manhwa.fromJson(json)).toList();
}
