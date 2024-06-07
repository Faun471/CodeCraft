import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/auth/auth_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_user.g.dart';

class AppUserState {
  final Map<String, dynamic> data;

  String? get email => data['email'] as String?;
  String? get displayName => data['displayName'] as String?;
  String? get accountType => data['accountType'] as String?;
  int? get level => data['level'] as int?;
  String? get orgId => data['orgId'] as String?;
  List<String>? get completedChallenges =>
      (data['completedChallenges'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList();

  AppUserState({required this.data});
}

@riverpod
class AppUserNotifier extends _$AppUserNotifier {
  @override
  FutureOr<AppUserState> build() async {
    return AppUserState(
      data: await _fetchData(),
    );
  }

  Future<Map<String, dynamic>> _fetchData() async {
    Map<String, dynamic> state = {};

    if (ref.watch(authProvider).isLoggedIn()) {
      await DatabaseHelper().currentUser.get().then((doc) {
        if (doc.exists) {
          state = doc.data() as Map<String, dynamic>;
        }
      });
    } else {}

    return state;
  }

  Future<void> updateData(Map<String, dynamic> newData) async {
    try {
      state = const AsyncValue.loading();
      var updatedData = {...(state.value!.data), ...newData};
      await DatabaseHelper()
          .currentUser
          .set(updatedData, SetOptions(merge: true));
      state = AsyncValue.data(AppUserState(data: updatedData));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> levelUp() async {
    try {
      state = const AsyncValue.loading();
      final newLevel = ((state.value!.data['level'] ?? 0) + 1);
      await updateData({'level': newLevel});
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
