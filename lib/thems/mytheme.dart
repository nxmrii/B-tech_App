import 'package:flutter/material.dart';


ThemeData myTheme = ThemeData(
  colorScheme: const ColorScheme.dark(  // Using dark colors for this example
    background: Color(0xff074159), // Background color (dark blue)
    primary: Color(0xff0C4E68), // Text color (darker blue)
    secondary: Color(0xff4270B5), // Hint text color (lighter blue)
    tertiary: Color(0xffC7E2ED), // Bottom bar color (teal)
    inversePrimary: Color(0xffFEE9D4), // Optional: Inverted primary (light yellow)
    inverseSurface: Color(0xffF5F5F5), // Optional: Light surface color
    tertiaryContainer: Color(0xff303030), // Container color for text (dark gray)
    onBackground: Color(0xffFFFFFF), // Text color on background (white)
  ),
);