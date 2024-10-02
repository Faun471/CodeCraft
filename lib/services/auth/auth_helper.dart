import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/main.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/additional_info.dart';
import 'package:codecraft/screens/apprentice/apprentice_home.dart';
import 'package:codecraft/screens/mentor/mentor_home.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_helper.g.dart';

class AuthState {
  User? user;

  AuthState({required this.user});
}

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<AuthState> build() {
    return AuthState(user: FirebaseAuth.instance.currentUser);
  }

  Future<String?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          "831166027593-53rh04dgchjmgj0348m05pl6g6tru9c2.apps.googleusercontent.com",
    );

    await googleSignIn.signOut();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleSignIn.signIn().then((value) => value!.authentication);

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        return 'An error occurred while signing in with Google.';
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>?;

      final appUser = await ref.refresh(appUserNotifierProvider.future);

      if (userData == null ||
          !userDoc.exists ||
          !userData.containsKey('accountType')) {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => AccountSetup(
              AdditionalInfoScreen(user: userCredential.user!),
            ),
          ),
        );
      } else {
        if (appUser.accountType == 'mentor') {
          navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MentorHome(),
            ),
          );
        } else {
          navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ApprenticeHome(),
            ),
          );
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          return 'The account already exists with a different credential.';
        case 'invalid-credential':
          return 'Error occurred while accessing credentials. Try again.';
        case 'operation-not-allowed':
          return 'Error occurred while accessing credentials. Try again.';
        case 'user-disabled':
          return 'The user has been disabled.';
        case 'user-not-found':
          return 'User not found. Please register first.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'invalid-verification-id':
          return 'Invalid verification ID.';
        default:
          return e.toString();
      }
    }
  }

  Future<String?> registerUser(
    Map<String, String> userData,
    String accountType,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userData['email']!,
        password: userData['password']!,
      );

      String userId = userCredential.user!.uid;
      String orgId = accountType == 'mentor'
          ? await DatabaseHelper().createOrganization(userId)
          : DatabaseHelper.defaultOrgId;

      await DatabaseHelper().createUser(userId, userData, accountType, orgId);
      return 'success';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.';
        default:
          return e.toString();
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // return null on success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.';
        default:
          return e.toString();
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateUser(
    WidgetRef? ref, {
    String? displayName,
    String? firstName,
    String? mi,
    String? lastName,
    String? suffix,
    String? phoneNumber,
  }) async {
    if (displayName != null && displayName.isNotEmpty) {
      state.value!.user!.updateDisplayName(displayName);
    }

    Map<String, String?> updates = {
      if (displayName != null && displayName.isNotEmpty)
        'displayName': displayName,
      if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
      if (mi != null && mi.isNotEmpty) 'mi': mi,
      if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
      if (suffix != null && suffix.isNotEmpty) 'suffix': suffix,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber,
    };

    if (updates.isNotEmpty) {
      await DatabaseHelper().currentUser.set(updates, SetOptions(merge: true));
      if (ref != null) {
        await ref.watch(appUserNotifierProvider.notifier).updateData(updates);
      }
    }

    return Future.value();
  }
}
