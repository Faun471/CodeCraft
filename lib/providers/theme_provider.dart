import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

class ThemeState {
  final Color preferredColor;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemeState({
    required this.preferredColor,
    required this.lightTheme,
    required this.darkTheme,
  });

  ThemeState copyWith({
    Color? preferredColor,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      preferredColor: preferredColor ?? this.preferredColor,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  FutureOr<ThemeState> build() async {
    final color = await _fetchPreferredColor();
    final newState = _createThemeState(color);
    return newState;
  }

  ThemeState _createThemeState(Color color) {
    return ThemeState(
      preferredColor: color,
      lightTheme: ThemeUtils.createLightTheme(color),
      darkTheme: ThemeUtils.createDarkTheme(color),
    );
  }

  Future<Color> _fetchPreferredColor() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return Colors.orange;
    }

    final user = await DatabaseHelper().currentUser.get();

    if (!user.exists) {
      return Colors.orange;
    }

    final userData = user.data() as Map<String, dynamic>;

    if (!userData.containsKey('preferredColor')) {
      return Colors.orange;
    }

    Color userDataColor =
        Color(int.parse(userData['preferredColor'], radix: 16));
        
    return userDataColor;
  }

  Future<void> updateColor(Color newColor) async {
    state = const AsyncValue.loading();

    await DatabaseHelper().currentUser.set({
      'preferredColor': newColor.value.toRadixString(16),
    }, SetOptions(merge: true));

    final newState = _createThemeState(newColor);
    state = AsyncValue.data(newState);
  }
}
