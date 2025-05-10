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
  int minYear = 1995;
  int maxYear = DateTime.now().year;
  int minChapters = 0;

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
          minChapters: minChapters,
          minYearReleased: minYear,
          maxYearReleased: maxYear,
        ),
        onFallback: _showSnackBar,
      );

      if (!mounted) return;

      Navigator.pop(context); // remove loading spinner

      if (result.isEmpty) {
        _showSnackBar("No results found.");
        return;
      }

      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => ResultPopup(manhwas: result),
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
      return Scaffold(
        appBar: AppBar(title: const Text('Manhwa Finder')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manhwa Finder')),
      body: Padding(
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
              matchAll: true,
            ),
            const SizedBox(height: 24),

            MultiSelectDropdown(
              label: 'Categories',
              items: categories.map((c) => c.name).toList(),
              selectedItems: selectedCategories,
              onSelectionChanged: (values) {
                setState(() => selectedCategories = values);
              },
              matchAll: true,
            ),
            const SizedBox(height: 24),

            MultiSelectDropdown(
              label: 'Ratings',
              items: ratings.map((r) => r.name).toList(),
              selectedItems: selectedRatings,
              onSelectionChanged: (values) {
                setState(() => selectedRatings = values);
              },
              matchAll: false,
            ),
            const SizedBox(height: 24),

            MultiSelectDropdown(
              label: 'Status',
              items: status.map((s) => s.name).toList(),
              selectedItems: selectedStatus,
              onSelectionChanged: (values) {
                setState(() => selectedStatus = values);
              },
              matchAll: false,
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chapters', style: TextStyle(fontSize: 16)),
                Slider(
                  value: minChapters.toDouble(),
                  min: 0,
                  max: 400,
                  divisions: 100,
                  label: '$minChapters+',
                  onChanged: (value) {
                    setState(() {
                      minChapters = value.round();
                    });
                  },
                ),
                Text('Only show manhwas with $minChapters+ chapters'),
              ],
            ),
            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Year Released', style: TextStyle(fontSize: 16)),
                RangeSlider(
                  values: RangeValues(minYear.toDouble(), maxYear.toDouble()),
                  min: 1995,
                  max: DateTime.now().year.toDouble(),
                  labels: RangeLabels('$minYear', '$maxYear'),
                  divisions: DateTime.now().year - 1995,
                  onChanged: (values) {
                    setState(() {
                      minYear = values.start.round();
                      maxYear = values.end.round();
                    });
                  },
                ),
                Text('Between $minYear and $maxYear'),
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _showResults,
              style: ElevatedButton.styleFrom(
                minimumSize: Size((MediaQuery.sizeOf(context).width * 0.5), 50),
              ),
              child: const Text('Find'),
            ),
          ],
        ),
      ),
    );
  }
}
