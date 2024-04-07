import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

  Future<String?> registerUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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

  Future<String?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    try {
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
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

  Future<void> updateUser(
      {String username = '', String profilePictureUrl = ''}) {
    if (username.isNotEmpty) {
      // update the username
    }

    if (profilePictureUrl.isNotEmpty) {
      // update the profile picture
    }

    //TODO implement this
    throw UnimplementedError();
  }
}
