import 'package:codesensei/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightModeTheme(BuildContext context) {
  return ThemeData.light().copyWith(
    primaryColor: primaryColor,
      scaffoldBackgroundColor: LightModeColor,
      appBarTheme: AppBarTheme(centerTitle: false, elevation: 0),
      textTheme: GoogleFonts.ubuntuTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: DarkModeColor),
      navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: LightModeColor,
          indicatorColor: primaryColor.withOpacity(0.3),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: DarkModeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                }
                return TextStyle(
                  color: DarkModeColor.withOpacity(0.9),
                  fontSize: 14,
                );
              }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                  (Set<WidgetState> states) {
                return IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : DarkModeColor.withOpacity(0.32),
                );
              })),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DarkModeColor,
            elevation:0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
      ),
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color:DarkModeColor)
          ),filled: true,
          fillColor: Colors.grey[450],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          )
      ));
}
ThemeData DarkModeTheme(BuildContext context){
  return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
    scaffoldBackgroundColor: DarkModeColor,
      appBarTheme: AppBarTheme(centerTitle: false, elevation: 0),
      textTheme: GoogleFonts.ubuntuTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: LightModeColor),
      navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: DarkModeColor,
          indicatorColor: primaryColor.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: LightModeColor.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  );
                }
                return TextStyle(
                  color: LightModeColor.withOpacity(0.32),
                  fontSize: 14,
                );
              }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                  (Set<WidgetState> states) {
                return IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? primaryColor
                      : LightModeColor.withOpacity(0.32),
                );
              })),

  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightModeColor,
        elevation:0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      )
  ),
      inputDecorationTheme: InputDecorationTheme(
  labelStyle: TextStyle(
    color: Colors.white,
  ),
  focusedBorder: OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color:LightModeColor)
  ),filled: true,
  fillColor: Colors.grey[450],
  border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide.none,
  )
  ));
}
