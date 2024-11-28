import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A class representing the state of the screen navigation stack.
///
/// It contains a list of widgets representing the screens in the stack
/// and a list of integers representing the navigation history.
class ScreenState {
  final List<Widget> screenStack;
  final List<int> navigationHistory;

  ScreenState({required this.screenStack, required this.navigationHistory});
}

/// A StateNotifier that manages the screen navigation stack.
///
/// It provides methods to push, pop, replace, and navigate to screens
/// in the stack.
class ScreenNotifier extends StateNotifier<ScreenState> {
  ScreenNotifier()
      : super(ScreenState(screenStack: [Container()], navigationHistory: []));

  /// Pushes a new screen onto the stack.
  ///
  /// The new screen is added to the end of the screen stack and the
  /// current index is added to the navigation history.
  void pushScreen(Widget screen) {
    state = ScreenState(
      screenStack: [...state.screenStack, screen],
      navigationHistory: [
        ...state.navigationHistory,
        state.screenStack.length - 1
      ],
    );
  }

  /// Pops the top screen from the stack.
  ///
  /// The top screen is removed from the screen stack and the navigation
  /// history.
  void popScreen() {
    if (state.screenStack.length > 1) {
      final newStack = List<Widget>.from(state.screenStack)..removeLast();
      final newHistory = List<int>.from(state.navigationHistory)..removeLast();
      state = ScreenState(screenStack: newStack, navigationHistory: newHistory);
    }
  }

  /// Replaces the top screen in the stack with a new screen.
  ///
  /// The top screen is replaced with the new screen in the screen stack.
  /// The navigation history remains the same.
  ///
  /// If the screen stack is empty, the new screen is not added.
  ///
  /// [screen] - The new screen to replace the top screen with.
  void replaceScreen(Widget screen) {
    if (state.screenStack.isNotEmpty) {
      final newStack = List<Widget>.from(state.screenStack)
        ..removeLast()
        ..add(screen);
      state = ScreenState(
          screenStack: newStack, navigationHistory: state.navigationHistory);
    }
  }

  /// Navigates to the screen at the specified index in the stack.
  ///
  /// The screen stack is trimmed to the specified index and the navigation
  /// history is updated to include only the indices up to the specified index.
  void navigateToIndex(int index) {
    if (index >= 0 && index < state.screenStack.length) {
      final newStack = state.screenStack.sublist(0, index + 1);
      final newHistory =
          state.navigationHistory.where((i) => i <= index).toList();
      state = ScreenState(screenStack: newStack, navigationHistory: newHistory);
    }
  }
}

/// A provider that exposes a [ScreenNotifier] to manage the screen navigation stack.
/// It provides a [ScreenState] object that represents the current state of the stack.
/// It is used to push, pop, replace, and navigate to screens in the stack.
///
/// Usage:  ref.read(screenProvider.notifier).pushScreen(MyScreen());
///         ref.watch(screenProvider).screenStack;
///         ref.watch(screenProvider).navigationHistory;
final screenProvider = StateNotifierProvider<ScreenNotifier, ScreenState>(
    (ref) => ScreenNotifier());
