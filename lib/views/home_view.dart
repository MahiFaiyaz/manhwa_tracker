import 'package:flutter/material.dart';
import '../widgets/result_popup.dart';
import '../services/api_services.dart';
import '../widgets/multi_select_dropdown.dart';
import '../models/models.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Genre> genres = [];
  List<Category> categories = [];
  List<Status> status = [];
  List<Rating> ratings = [];

  bool isLoading = true;
  List<String> selectedGenres = [];
  List<String> selectedCategories = [];
  List<String> selectedStatus = [];
  List<String> selectedRatings = [];

  @override
  void initState() {
    super.initState();
    _loadAllDropdownData();
  }

  Future<void> _loadAllDropdownData() async {
    setState(() {
      isLoading = true;
    });

    late List<Genre> loadedGenres;
    late List<Category> loadedCategories;
    late List<Status> loadedStatus;
    late List<Rating> loadedRatings;

    // Run all fetch calls in parallel
    await Future.wait([
      fetchGenres(
        onFallback: _showSnackBar,
      ).then((result) => loadedGenres = result),
      fetchCategories(
        onFallback: _showSnackBar,
      ).then((result) => loadedCategories = result),
      fetchStatus(
        onFallback: _showSnackBar,
      ).then((result) => loadedStatus = result),
      fetchRatings(
        onFallback: _showSnackBar,
      ).then((result) => loadedRatings = result),
    ]);

    if (!mounted) return;

    setState(() {
      genres = loadedGenres;
      categories = loadedCategories;
      status = loadedStatus;
      ratings = loadedRatings;
      isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => ResultPopup(
            genres: selectedGenres,
            categories: selectedCategories,
            status: selectedStatus,
            ratings: selectedRatings,
          ),
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
          MultiSelectDropdown(
            label: 'Genres',
            items: genres.map((g) => g.name).toList(),
            selectedItems: selectedGenres,
            onSelectionChanged: (values) {
              setState(() => selectedGenres = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Categories',
            items: categories.map((c) => c.name).toList(),
            selectedItems: selectedCategories,
            onSelectionChanged: (values) {
              setState(() => selectedCategories = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Ratings',
            items: ratings.map((r) => r.name).toList(),
            selectedItems: selectedRatings,
            onSelectionChanged: (values) {
              setState(() => selectedRatings = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Status',
            items: status.map((s) => s.name).toList(),
            selectedItems: selectedStatus,
            onSelectionChanged: (values) {
              setState(() => selectedStatus = values);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showResults,
            style: ElevatedButton.styleFrom(
              minimumSize: Size((MediaQuery.sizeOf(context).width * 0.5), 50),
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
