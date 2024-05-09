import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/widgets/custom_text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

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
      Dialogs.materialDialog(
        context: context,
        msg: 'Password Reset Link Sent to Your Email Address',
        titleStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
        title: 'Success',
        msgStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
        lottieBuilder: Lottie.asset(
          'assets/anim/congrats.json',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          repeat: false,
        ),
        dialogWidth: 0.25,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromARGB(255, 21, 21, 21),
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'Close',
            iconData: Icons.close,
            color: Colors.green,
            textStyle: TextStyle(
              color: Colors.white,
            ),
            iconColor: Colors.white,
          ),
        ],
      );
    } on FirebaseAuthException catch (e) {
      Dialogs.materialDialog(
        context: context,
        msg: e.message!,
        titleStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
        title: 'Error',
        msgStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
        lottieBuilder: Lottie.asset(
          'assets/anim/error.json',
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
        dialogWidth: 0.25,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromARGB(255, 21, 21, 21),
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'Close',
            iconData: Icons.close,
            color: Colors.red,
            textStyle: TextStyle(
              color: Colors.white,
            ),
            iconColor: Colors.white,
          ),
        ],
      );
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
