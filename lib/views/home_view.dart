import 'package:flutter/material.dart';
import '../widgets/result_popup.dart';
import '../services/api_services.dart';
import '../widgets/multi_select_dropdown.dart';
import '../models/models.dart';
import '../models/manhwa_filter.dart';

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
  int minYear = 1980;
  int maxYear = 2025;
  int minChapters = 0;
  int maxChapters = 1000;

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

  void _showResults() async {
    showDialog(
      // optional loading indicator
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await fetchManhwas(
        filter: ManhwaFilter(
          genres: selectedGenres,
          categories: selectedCategories,
          status: selectedStatus,
          ratings: selectedRatings,
          minChapters: 0,
          maxChapters: 0,
          minYearReleased: 0,
          maxYearReleased: 0,
        ),
        onFallback: _showSnackBar,
      );

      if (!mounted) return;

      Navigator.pop(context); // remove loading spinner

      if (result.manhwas.isEmpty && !result.fromFallback) {
        _showSnackBar("No results found.");
        return;
      }

      if (result.manhwas.isEmpty && result.fromFallback) {
        // Already showed fallback message inside fetch
        return;
      }

      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => ResultPopup(manhwas: result.manhwas),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // remove loading spinner
      _showSnackBar("Failed to load results: $e");
    }
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

          Column(
            children: [
              Text(
                'Year Released',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: RangeValues(minYear.toDouble(), maxYear.toDouble()),
                min: 1980,
                max: 2025,
                divisions: 45,
                labels: RangeLabels('$minYear', '$maxYear'),
                onChanged: (RangeValues values) {
                  setState(() {
                    minYear = values.start.round();
                    maxYear = values.end.round();
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Min: $minYear'), Text('Max: $maxYear')],
            ),
          ),
          Column(
            children: [
              Text(
                'Chapters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: RangeValues(
                  minChapters.toDouble(),
                  maxChapters.toDouble(),
                ),
                min: 0,
                max: 1000,
                divisions: 50,
                labels: RangeLabels('$minChapters', '$maxChapters'),
                onChanged: (RangeValues values) {
                  setState(() {
                    minChapters = values.start.round();
                    maxChapters = values.end.round();
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Min: $minChapters'), Text('Max: $maxChapters')],
            ),
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
