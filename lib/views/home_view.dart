import 'package:flutter/material.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/result_popup.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Placeholder selected values
  String? selectedGenre;
  String? selectedCategory;
  String? selectedRating;
  String? selectedStatus;

  void _showResults() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const ResultPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterDropdown(
            label: 'Genre',
            value: selectedGenre,
            items: ['Action', 'Romance', 'Comedy'],
            onChanged: (val) => setState(() => selectedGenre = val),
          ),
          FilterDropdown(
            label: 'Category',
            value: selectedCategory,
            items: ['Main', 'Side', 'Bonus'],
            onChanged: (val) => setState(() => selectedCategory = val),
          ),
          FilterDropdown(
            label: 'Rating',
            value: selectedRating,
            items: ['G', 'PG', 'R'],
            onChanged: (val) => setState(() => selectedRating = val),
          ),
          FilterDropdown(
            label: 'Status',
            value: selectedStatus,
            items: ['Ongoing', 'Completed', 'Hiatus'],
            onChanged: (val) => setState(() => selectedStatus = val),
          ),
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
