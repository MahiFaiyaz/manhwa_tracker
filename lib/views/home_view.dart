import 'package:flutter/material.dart';
import '../widgets/result_popup.dart';
import '../services/api_services.dart';
import '../widgets/multi_select_dropdown.dart';

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
  List<String> selectedGenres = [];
  List<String> selectedCategories = [];
  List<String> selectedStatuses = [];
  List<String> selectedRatings = [];

  @override
  void initState() {
    super.initState();
    _loadAllDropdownData();
  }

  Future<void> _loadAllDropdownData() async {
    final results = await Future.wait([
      fetchGenres(),
      fetchCategories(),
      fetchStatus(),
      fetchRatings(),
    ]);

    setState(() {
      genres = results[0];
      categories = results[1];
      status = results[2];
      ratings = results[3];
      isLoading = false;
    });
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (context) => const ResultPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.sizeOf(context).width * 0.5);

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
            items: genres.map((g) => g['name'] as String).toList(),
            selectedItems: selectedGenres,
            onSelectionChanged: (values) {
              setState(() => selectedGenres = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Categories',
            items: categories.map((c) => c['name'] as String).toList(),
            selectedItems: selectedCategories,
            onSelectionChanged: (values) {
              setState(() => selectedCategories = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Ratings',
            items: ratings.map((r) => r['name'] as String).toList(),
            selectedItems: selectedRatings,
            onSelectionChanged: (values) {
              setState(() => selectedRatings = values);
            },
          ),
          const SizedBox(height: 24),

          MultiSelectDropdown(
            label: 'Status',
            items: status.map((s) => s['name'] as String).toList(),
            selectedItems: selectedStatuses,
            onSelectionChanged: (values) {
              setState(() => selectedStatuses = values);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showResults,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(buttonWidth, 50),
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
