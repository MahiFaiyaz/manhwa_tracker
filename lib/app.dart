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
                ),
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,

                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade300, // background
                    foregroundColor: Colors.grey.shade200, // text/icon color
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade300,
                    textStyle: const TextStyle(fontSize: 13),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                sliderTheme: SliderThemeData(
                  activeTrackColor: Colors.deepPurple.shade300,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.deepPurple.shade200,
                ),
                popupMenuTheme: PopupMenuThemeData(
                  color: Colors.deepPurple.shade300,
                  textStyle: TextStyle(
                    color: Colors.grey.shade200,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // match button shape
                  ),
                  elevation: 8, // same as ElevatedButton
                ),
              ),

              home: const RootView(),
            ),
          ),
        );
      },
    );
  }
}
