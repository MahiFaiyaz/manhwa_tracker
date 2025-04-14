import 'package:flutter/material.dart';

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

  void _showSelectionModal(BuildContext context) async {
    List<String> tempSelected = [...selectedItems];
    final height = MediaQuery.sizeOf(context).height;

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: height * 0.7, // almost full screen
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        "Select $label",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = tempSelected.contains(item);

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempSelected.remove(item);
                                } else {
                                  tempSelected.add(item);
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
                                        ? Colors.purple[900]
                                        : Colors.white,
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      onSelectionChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        selectedItems.isEmpty ? 'Select $label' : selectedItems.join(', ');

    return Material(
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showSelectionModal(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(displayText),
        ),
      ),
    );
  }
}
