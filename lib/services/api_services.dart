import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/widgets.dart';
import '../models/manhwa_filter.dart';
import 'auth_services.dart';

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

Future<List<Manhwa>> fetchManhwas({
  required ManhwaFilter filter,
  void Function(String)? onFallback,
}) async {
  try {
    final token = session?.accessToken;

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'auth-token': 'Bearer $token',
    };
    final response = await http.post(
      Uri.parse('$apiBaseUrl/manhwas'),
      headers: headers,
      body: jsonEncode(filter.toJson()),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Manhwa.fromJson(json)).toList();
    } else {
      throw Exception('Bad status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("Manhwa fetch failed: $e");
    if (onFallback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onFallback.call("Failed to load manhwas. Please try again later.");
      });
    }
    return [];
  }
}

Future<List<Manhwa>> fetchUserProgress({
  void Function(String)? onFallback,
}) async {
  try {
    final token = session?.accessToken;
    if (token == null) throw Exception("Missing auth token");

    final response = await http.get(
      Uri.parse('$apiBaseUrl/progress'),
      headers: {
        'Content-Type': 'application/json',
        'auth-token': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Manhwa.fromJson(json)).toList();
    } else {
      throw Exception('Progress fetch failed: status ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("Progress API failed: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFallback?.call("Failed to load your library.");
    });

    return [];
  }
}

Future<bool> submitProgress({
  required int manhwaId,
  required int chapter,
  required String readingStatus,
}) async {
  try {
    final token = session?.accessToken;
    if (token == null) throw Exception("Missing auth token");

    final response = await http.post(
      Uri.parse('$apiBaseUrl/progress'),
      headers: {
        'Content-Type': 'application/json',
        'auth-token': 'Bearer $token',
      },
      body: jsonEncode({
        'manhwa_id': manhwaId,
        'current_chapter': chapter,
        'reading_status': readingStatus,
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    debugPrint("Progress update failed: $e");
    return false;
  }
}

Future<bool> deleteProgress(int manhwaId) async {
  try {
    final token = session?.accessToken;
    if (token == null) throw Exception("Missing auth token");

    final response = await http.delete(
      Uri.parse('$apiBaseUrl/progress/$manhwaId'),
      headers: {
        'Content-Type': 'application/json',
        'auth-token': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    debugPrint("Progress delete failed: $e");
    return false;
  }
}
