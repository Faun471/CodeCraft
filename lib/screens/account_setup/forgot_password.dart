import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      if (!mounted) {
        return;
      }

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
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: Text(
            'Please Provide Your Email Address to Receive a Password Reset Link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: CustomTextField(
            labelText: 'Email',
            icon: Icons.email,
            controller: _emailController,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange,
            ),
            child: MaterialButton(
              onPressed: () async {
                await passwordReset();
              },
              minWidth: double.infinity,
              height: 50.0, //call out niyo na lang dito si passwordReset
              child: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
