import 'package:flutter/material.dart';
import '../widgets/result_popup.dart';
import '../services/api_services.dart';
import '../widgets/multi_select_dropdown.dart';
import '../models/models.dart';
import '../models/manhwa_filter.dart';
import '../dialog/loading_screen.dart';

const stackSpace = SizedBox(height: 14);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoadingScreen.instance().show(context: context, text: "Loading Data...");
      _loadAllDropdownData();
    });
  }

  Future<void> _loadAllDropdownData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final results = await Future.wait([
        fetchGenres(onFallback: _showSnackBar),
        fetchCategories(onFallback: _showSnackBar),
        fetchStatus(onFallback: _showSnackBar),
        fetchRatings(onFallback: _showSnackBar),
      ]);

      if (!mounted) return;

      setState(() {
        genres = results[0] as List<Genre>;
        categories = results[1] as List<Category>;
        status = results[2] as List<Status>;
        ratings = results[3] as List<Rating>;

        isLoading = false;
      });
    } catch (e) {
      _showSnackBar("Failed to load filter data.");
      setState(() => isLoading = false);
    } finally {
      if (mounted) {
        LoadingScreen.instance().hide();
      }
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Manhwa Finder')),
      body: SingleChildScrollView(
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
            stackSpace,

            MultiSelectDropdown(
              label: 'Categories',
              items: categories.map((c) => c.name).toList(),
              selectedItems: selectedCategories,
              onSelectionChanged: (values) {
                setState(() => selectedCategories = values);
              },
              matchAll: true,
            ),
            stackSpace,

            MultiSelectDropdown(
              label: 'Ratings',
              items: ratings.map((r) => r.name).toList(),
              selectedItems: selectedRatings,
              onSelectionChanged: (values) {
                setState(() => selectedRatings = values);
              },
              matchAll: false,
            ),
            stackSpace,

            MultiSelectDropdown(
              label: 'Status',
              items: status.map((s) => s.name).toList(),
              selectedItems: selectedStatus,
              onSelectionChanged: (values) {
                setState(() => selectedStatus = values);
              },
              matchAll: false,
            ),
            stackSpace,
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
            stackSpace,

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

            stackSpace,

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
