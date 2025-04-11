import 'package:flutter/material.dart';

class ResultPopup extends StatelessWidget {
  const ResultPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.83, // almost full screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
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
