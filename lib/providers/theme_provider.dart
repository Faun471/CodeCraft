import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

class ThemeState {
  final Color preferredColor;

  ThemeState({required this.preferredColor});

  ThemeState copyWith({Color? preferredColor}) {
    return ThemeState(preferredColor: preferredColor ?? this.preferredColor);
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  FutureOr<ThemeState> build() async {
    return ThemeState(preferredColor: await _fetchPreferredColor());
  }

  Future<Color> _fetchPreferredColor() async {
    final user = await DatabaseHelper().currentUser.get();
    final userData = user.data() as Map<String, dynamic>;

    final String preferredColor =
        userData['preferredColor'] ?? Colors.orange.value.toRadixString(16);

    return Color(int.parse(preferredColor, radix: 16));
  }

  Future<void> updateColor(Color newColor, BuildContext context) async {
    state = const AsyncValue.loading();

    await DatabaseHelper().currentUser.set({
      'preferredColor': newColor.value.toRadixString(16),
    }, SetOptions(merge: true));

    state = AsyncValue.data(ThemeState(preferredColor: newColor));

    if (!context.mounted) {
      return;
    }

    _updateTheme(context);
  }

  void _updateTheme(BuildContext context) {
    state.when(
      data: (themeState) {
        final lightTheme =
            _createLightTheme(context, themeState.preferredColor);
        final darkTheme = _createDarkTheme(context, themeState.preferredColor);

        AdaptiveTheme.of(context).setTheme(
          light: lightTheme,
          dark: darkTheme,
        );
      },
      loading: () {},
      error: (error, stack) {},
    );
  }

  ThemeData _createLightTheme(BuildContext context, Color color) {
    return AppTheme.lightTheme.copyWith(
      primaryColor: color,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: color,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStateProperty.all(color),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              side: WidgetStateProperty.all(
                BorderSide(color: color),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              color: color,
            ),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(
              color: Colors.blueGrey,
            ),
      ),
    );
  }

  ThemeData _createDarkTheme(BuildContext context, Color color) {
    return AppTheme.darkTheme.copyWith(
      primaryColor: color,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: color,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              backgroundColor: WidgetStateProperty.all(color),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              side: WidgetStateProperty.all(
                BorderSide(color: color),
              ),
            ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle!.copyWith(
              color: color,
            ),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle!.copyWith(
              color: Colors.blueGrey,
            ),
      ),
    );
  }
}
