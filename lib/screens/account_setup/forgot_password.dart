import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:codecraft/utils/utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim());

        if (!context.mounted) {
          return;
        }

        Utils.displayDialog(
          context: context,
          title: 'Success',
          content: 'Password reset link has been sent to your email.',
          lottieAsset: 'assets/anim/congrats.json',
          buttonText: 'Close',
          onPressed: () => Navigator.pop(context),
        );
      } on FirebaseAuthException catch (e) {
        Utils.displayDialog(
          context: context,
          title: 'Error',
          content: e.message!,
          lottieAsset: 'assets/anim/error.json',
          buttonText: 'Close',
          onPressed: () => Navigator.pop(context),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'Forgot Password',
              style: AdaptiveTheme.of(context).theme.textTheme.displayLarge,
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Please Provide Your Email Address to Receive a Password Reset Link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: CustomTextField(
              labelText: 'Email',
              icon: Icons.email,
              controller: emailController,
              autofillHint: AutofillHints.email,
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Center(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async => await _sendPasswordResetEmail(context),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60)),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Send Reset Link'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const AccountSetup(Login());
              }));
            },
            child: Text(
              'Back to Login',
              style: AdaptiveTheme.of(context)
                  .theme
                  .textTheme
                  .labelLarge!
                  .copyWith(
                    decoration: TextDecoration.underline,
                    color: AdaptiveTheme.of(context).theme.primaryColor,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
