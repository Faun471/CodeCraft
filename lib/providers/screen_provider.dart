import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenState {
  final List<Widget> screenStack;
  final List<int> navigationHistory;

  ScreenState({required this.screenStack, required this.navigationHistory});
}

class ScreenNotifier extends StateNotifier<ScreenState> {
  ScreenNotifier()
      : super(ScreenState(screenStack: [Container()], navigationHistory: []));

  void pushScreen(Widget screen) {
    state = ScreenState(
      screenStack: [...state.screenStack, screen],
      navigationHistory: [
        ...state.navigationHistory,
        state.screenStack.length - 1
      ],
    );
  }

  void popScreen() {
    if (state.screenStack.length > 1) {
      final newStack = List<Widget>.from(state.screenStack)..removeLast();
      final newHistory = List<int>.from(state.navigationHistory)..removeLast();
      state = ScreenState(screenStack: newStack, navigationHistory: newHistory);
    }
  }

  void replaceScreen(Widget screen) {
    if (state.screenStack.isNotEmpty) {
      final newStack = List<Widget>.from(state.screenStack)
        ..removeLast()
        ..add(screen);
      state = ScreenState(
          screenStack: newStack, navigationHistory: state.navigationHistory);
    }
  }

  void navigateToIndex(int index) {
    if (index >= 0 && index < state.screenStack.length) {
      final newStack = state.screenStack.sublist(0, index + 1);
      final newHistory =
          state.navigationHistory.where((i) => i <= index).toList();
      state = ScreenState(screenStack: newStack, navigationHistory: newHistory);
    }
  }
}

final screenProvider = StateNotifierProvider<ScreenNotifier, ScreenState>(
    (ref) => ScreenNotifier());
