import 'package:flutter/material.dart';
import './custom_chip.dart';

class MultiSelectDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onSelectionChanged;

  const MultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  void _showSelectionModal(BuildContext context) {
    List<String> tempSelected = [...selectedItems];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _MultiSelectModalContent(
          label: label,
          items: items,
          tempSelected: tempSelected,
        );
      },
    ).then((_) {
      onSelectionChanged(
        tempSelected,
      ); // Always return whatever was last selected
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayContent = SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
            selectedItems.isEmpty
                ? Text(
                  "Select $label",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                )
                : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      selectedItems.map((item) => customChip(item)).toList(),
                ),
      ),
    );

    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showSelectionModal(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 22, // increase size
              fontWeight: FontWeight.bold, // make it bold
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: displayContent,
          ),
        ),
      ),
    );
  }
}

class _MultiSelectModalContent extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> tempSelected;

  const _MultiSelectModalContent({
    required this.label,
    required this.items,
    required this.tempSelected,
  });

  @override
  State<_MultiSelectModalContent> createState() =>
      _MultiSelectModalContentState();
}

class _MultiSelectModalContentState extends State<_MultiSelectModalContent> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select ${widget.label}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.tempSelected.clear();
                    });
                  },
                  child: const Text(
                    "Clear All",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = widget.tempSelected.contains(item);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          widget.tempSelected.remove(item);
                        } else {
                          widget.tempSelected.add(item);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            isSelected
                                ? Colors.deepPurple.shade200
                                : Colors.white,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size((MediaQuery.sizeOf(context).width * 0.5), 50),
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
