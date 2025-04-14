import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

Future<List<Map<String, dynamic>>> loadMockData(String filename) async {
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

  final String jsonString = await rootBundle.loadString(
    'lib/sample_data/$filename.json',
  );
  final List<dynamic> jsonData = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(jsonData);
}

Future<List<Genre>> fetchGenres() async {
  final data = await loadMockData('genres');
  return data.map((json) => Genre.fromJson(json)).toList();
}

Future<List<Category>> fetchCategories() async {
  final data = await loadMockData('categories');
  return data.map((json) => Category.fromJson(json)).toList();
}

Future<List<Status>> fetchStatus() async {
  final data = await loadMockData('status');
  return data.map((json) => Status.fromJson(json)).toList();
}

Future<List<Rating>> fetchRatings() async {
  final data = await loadMockData('rating');
  return data.map((json) => Rating.fromJson(json)).toList();
}

Future<List<Map<String, dynamic>>> fetchManhwas() => loadMockData('manhwas');
