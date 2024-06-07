import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenState {
  final List<Widget> screenStack;

  ScreenState({required this.screenStack});
}

class ScreenNotifier extends StateNotifier<ScreenState> {
  ScreenNotifier() : super(ScreenState(screenStack: [Container()]));

  void pushScreen(Widget screen) {
    state = ScreenState(screenStack: [...state.screenStack, screen]);
  }

  void popScreen() {
    if (state.screenStack.length > 1) {
      state =
          ScreenState(screenStack: List.from(state.screenStack)..removeLast());
    }
  }

  void replaceScreen(Widget screen) {
    if (state.screenStack.isNotEmpty) {
      state = ScreenState(
          screenStack: List.from(state.screenStack)
            ..removeLast()
            ..add(screen));
    }
  }
}

final screenProvider = StateNotifierProvider<ScreenNotifier, ScreenState>(
    (ref) => ScreenNotifier());
