import 'package:flutter/material.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/result_popup.dart';
import '../services/api_services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Map<String, dynamic>> genres = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> status = [];
  List<Map<String, dynamic>> ratings = [];

  bool isLoading = true;

  String? selectedGenre;
  String? selectedCategory;
  String? selectedStatus;
  String? selectedRating;

  @override
  void initState() {
    super.initState();
    _loadAllDropdownData();
  }

  Future<void> _loadAllDropdownData() async {
    final fetchedGenres = await fetchGenres();
    final fetchedCategories = await fetchCategories();
    final fetchedStatus = await fetchStatus();
    final fetchedRatings = await fetchRatings();

    setState(() {
      genres = fetchedGenres;
      categories = fetchedCategories;
      status = fetchedStatus;
      ratings = fetchedRatings;
      isLoading = false;
    });
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ResultPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterDropdown(
            label: 'Genre',
            value: selectedGenre,
            items: genres.map((g) => g['name'] as String).toList(),
            onChanged: (val) => setState(() => selectedGenre = val),
          ),
          // You can repeat similar mock fetch + FilterDropdown logic for Category, Rating, Status
          const SizedBox(height: 24),
          FilterDropdown(
            label: 'Category',
            value: selectedCategory,
            items: categories.map((g) => g['name'] as String).toList(),
            onChanged: (val) => setState(() => selectedCategory = val),
          ),
          // You can repeat similar mock fetch + FilterDropdown logic for Category, Rating, Status
          const SizedBox(height: 24),
          FilterDropdown(
            label: 'Rating',
            value: selectedRating,
            items: ratings.map((g) => g['name'] as String).toList(),
            onChanged: (val) => setState(() => selectedRating = val),
          ),
          // You can repeat similar mock fetch + FilterDropdown logic for Category, Rating, Status
          const SizedBox(height: 24),
          FilterDropdown(
            label: 'Status',
            value: selectedStatus,
            items: status.map((g) => g['name'] as String).toList(),
            onChanged: (val) => setState(() => selectedStatus = val),
          ),
          // You can repeat similar mock fetch + FilterDropdown logic for Category, Rating, Status
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showResults,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }
}
