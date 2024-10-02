import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user_notifier.g.dart';

@riverpod
class AppUserNotifier extends _$AppUserNotifier {
  @override
  FutureOr<AppUser> build() async {
    return await _fetchData();
  }

  Future<AppUser> _fetchData() async {
    AppUser user = state.value ?? AppUser();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return user;
    }

    print('Fetching user data for ${currentUser.uid}');

    // Fetch accurate data first
    if (user.isEmpty()) {
      final data = await DatabaseHelper().getUserData(currentUser.uid);
      user = AppUser.fromMap(data);
    }

    // Set up a listener to listen for changes
    DatabaseHelper().currentUser.snapshots().listen((doc) async {
      if (doc.exists) {
        user = AppUser.fromMap(doc.data() as Map<String, dynamic>);
      }
    });

    print('returning user: $user');

    return user;
  }

  Future<void> fillMissingData(Map<String, dynamic> data) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      if (data['id'] == null) {
        data['id'] = currentUser.uid;
      }

      if (data['photoURL'] == null) {
        data['photoURL'] = currentUser.photoURL;
      }

      if (data['displayName'] == null) {
        data['displayName'] = currentUser.displayName;
      }

      if (data['email'] == null) {
        data['email'] = currentUser.email;
      }

      await updateData(data);
    } else {
      state = AsyncValue.error("No authenticated user", StackTrace.current);
    }
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    try {
      state = const AsyncValue.loading();
      var updatedData = {
        ...(state.value!.toMap()),
        ...newData,
        'id': FirebaseAuth.instance.currentUser!.uid
      };
      await DatabaseHelper()
          .currentUser
          .set(updatedData, SetOptions(merge: true));
      state = AsyncValue.data(AppUser.fromMap(updatedData));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addExperience(int experience) async {
    try {
      state = const AsyncValue.loading();
      final currentExperience = state.value!.experience ?? 0;
      final newExperience = currentExperience + experience;

      if (newExperience >= 100) {
        final newLevel = (state.value!.level ?? 0) + 1;
        await updateData({
          'experience': newExperience - 100,
          'level': newLevel,
        });
      } else {
        await updateData({'experience': newExperience});
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Add this reset method
  void reset() {
    state = AsyncValue.data(AppUser());
  }
}
