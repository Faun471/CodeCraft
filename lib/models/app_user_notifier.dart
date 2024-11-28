import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/main.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user_notifier.g.dart';

@riverpod
class AppUserNotifier extends _$AppUserNotifier {
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  FutureOr<AppUser> build() async {
    // Cancel any existing subscription when the provider is rebuilt
    await _userSubscription?.cancel();
    return await _fetchAndListenToUserData();
  }

  Future<AppUser> _fetchAndListenToUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return AppUser();
    }

    final userDoc = DatabaseHelper().currentUser;

    // Set up a listener for real-time updates
    _userSubscription = userDoc.snapshots().listen((docSnapshot) {
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        state = AsyncValue.data(AppUser.fromMap(userData));
      }
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });

    // Fetch initial data
    final initialDoc = await userDoc.get();
    if (initialDoc.exists) {
      return AppUser.fromMap(initialDoc.data() as Map<String, dynamic>);
    } else {
      // If the document doesn't exist, create a new user
      final newUser = AppUser(id: currentUser.uid, email: currentUser.email);
      await userDoc.set(newUser.toMap());
      return newUser;
    }
  }

  Future<void> fillMissingData(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final updatedData = {
        'id': currentUser.uid,
        'displayName': currentUser.displayName,
        'email': currentUser.email,
        ...data,
      };

      if (updatedData['photoUrl'] == null || updatedData['photoUrl']!.isEmpty) {
        updatedData['photoUrl'] =
            'https://api.dicebear.com/9.x/thumbs/png?seed=${currentUser.uid}';
      }

      await updateData(updatedData);
    } else {
      state = AsyncValue.error("No authenticated user", StackTrace.current);
    }
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    try {
      final currentData = state.value?.toMap() ?? {};
      final updatedData = {
        ...currentData,
        ...newData,
        'id': FirebaseAuth.instance.currentUser!.uid
      };

      await DatabaseHelper()
          .currentUser
          .set(updatedData, SetOptions(merge: true));
      // The listener will update the state automatically
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addExperience(int experience) async {
    if (state.value == null) return;

    try {
      final currentExperience = state.value!.experience ?? 0;
      final newExperience = currentExperience + experience;

      if (newExperience >= 100) {
        final newLevel = (state.value!.level ?? 1) + 1;
        await updateData({
          'experience': newExperience - 100,
          'level': newLevel,
        });

        if (navigatorKey.currentState == null) return;

        if (navigatorKey.currentState!.mounted) {
          Utils.displayDialog(
            context: navigatorKey.currentState!.context,
            title: 'Level Up!',
            content: 'You have reached level $newLevel!',
            lottieAsset: 'assets/anim/level_up.json',
          );
        }
      } else {
        await updateData({'experience': newExperience});
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
