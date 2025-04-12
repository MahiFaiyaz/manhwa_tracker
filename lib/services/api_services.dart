import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Map<String, dynamic>>> loadMockData(String filename) async {
  final String jsonString = await rootBundle.loadString(
    'lib/sample_data/$filename.json',
  );
  final List<dynamic> jsonData = json.decode(jsonString);
  return List<Map<String, dynamic>>.from(jsonData);
}

Future<List<Map<String, dynamic>>> fetchGenres() => loadMockData('genres');
Future<List<Map<String, dynamic>>> fetchCategories() =>
    loadMockData('categories');
Future<List<Map<String, dynamic>>> fetchStatus() => loadMockData('status');
Future<List<Map<String, dynamic>>> fetchRatings() => loadMockData('rating');
Future<List<Map<String, dynamic>>> fetchManhwas() => loadMockData('manhwas');
