import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _auth;
  User? _user;

  Auth(this._auth) {
    _user = _auth.currentUser;
  }

  Future<bool> isLoggedIn() async {
    _user = _auth.currentUser;
    if (_user == null) {
      return false;
    }
    return true;
  }

  Future<String?> registerUser(
      Map<String, String> userData, String accountType) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
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
      await _auth.signInWithEmailAndPassword(
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

  static bool isPasswordValid(String password) {
    Pattern pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(pattern as String);
    return regex.hasMatch(password);
  }

  Future<String?> signInWithGoogle() async {
    await GoogleSignIn(
            clientId:
                "831166027593-53rh04dgchjmgj0348m05pl6g6tru9c2.apps.googleusercontent.com")
        .signOut();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
            clientId:
                "831166027593-53rh04dgchjmgj0348m05pl6g6tru9c2.apps.googleusercontent.com")
        .signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
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

  Future<void> updateUser({
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? mi,
    String? lastName,
    String? suffix,
    String? phoneNumber,
  }) async {
    if (displayName != null) {
      _user!.updateDisplayName(displayName);
    }

    if (photoUrl != null) {
      _user!.updatePhotoURL(photoUrl);
    }

    Map<String, String?> updates = {
      if (firstName != null) 'firstName': firstName,
      if (mi != null) 'mi': mi,
      if (lastName != null) 'lastName': lastName,
      if (suffix != null) 'suffix': suffix,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };

    if (updates.isNotEmpty) {
      await DatabaseHelper().currentUser.set(updates, SetOptions(merge: true));
    }

    return Future.value();
  }
}
