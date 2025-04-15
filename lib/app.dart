import 'package:flutter/material.dart';
import 'views/root_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Optional: limit max width for desktop users
        final double maxAllowedWidth = 600; // or 800, tweak as you like
        final double width =
            constraints.maxWidth > maxAllowedWidth
                ? maxAllowedWidth
                : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: width, maxWidth: width),
            child: MaterialApp(
              title: 'Manhwa Tracker',
              theme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  centerTitle: true,
                  surfaceTintColor: Colors.black12,
                ),
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              home: const RootView(),
            ),
          ),
        );
      },
    );
  }
}
