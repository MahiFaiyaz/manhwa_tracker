import 'package:flutter/material.dart';

class ResultPopup extends StatelessWidget {
  const ResultPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.83, // almost full screen
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder:
                  (context, index) => ListTile(
                    title: Text('Manhwa Result ${index + 1}'),
                    subtitle: const Text('Details about this manhwa...'),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
