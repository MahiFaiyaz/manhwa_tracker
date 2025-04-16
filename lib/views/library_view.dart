import 'package:flutter/material.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library')),
      body: Center(
        child: Text(
          'Coming soon',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
