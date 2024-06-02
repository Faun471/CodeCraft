import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await DatabaseHelper()
          .auth
          .sendPasswordResetEmail(email: _emailController.text.trim());

      Utils.displayDialog(
          context: context,
          title: 'Success',
          content: 'Password Reset Link Sent to Your Email Address',
          lottieAsset: 'assets/anim/congrats.json',
          buttonText: 'Close',
          onPressed: () => Navigator.pop(context));
    } on FirebaseAuthException catch (e) {
      Utils.displayDialog(
          context: context,
          title: 'Error',
          content: e.message!,
          lottieAsset: 'assets/anim/error.json',
          buttonText: 'Close',
          onPressed: () => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 25.0, top: 20.0),
          child: Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(
            'Please Provide Your Email Address to Receive a Password Reset Link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: CustomTextField(
            labelText: 'Email',
            icon: Icons.email,
            controller: _emailController,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange,
            ),
            child: MaterialButton(
              onPressed: () async {
                await passwordReset();
              }, //call out niyo na lang dito si passwordReset
              child: Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
              minWidth: double.infinity,
              height: 50.0,
            ),
          ),
        ),
      ],
    );
  }
}
