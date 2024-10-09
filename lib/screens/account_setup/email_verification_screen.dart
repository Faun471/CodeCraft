import 'dart:async';

import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/register.dart';
import 'package:codecraft/screens/apprentice/apprentice_home.dart';
import 'package:codecraft/screens/mentor/mentor_home.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerifScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerifScreen({super.key, required this.email});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerifScreen> {
  late Timer _timer;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isCheckingVerification) {
        _checkEmailVerification();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isCheckingVerification = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        _timer.cancel();
        await _navigateToNextScreen();
      } else {}
    } finally {
      if (mounted) {
        setState(() => _isCheckingVerification = false);
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final appUserState = await ref.refresh(appUserNotifierProvider.future);

    Widget nextScreen;
    switch (appUserState.accountType!) {
      case 'apprentice':
        nextScreen = const ApprenticeHome();
        break;
      case 'mentor':
        nextScreen = const MentorHome();
        break;
      default:
        nextScreen = const AccountSetup(Register());
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Email',
          style: TextStyle(
            color: ThemeUtils.getTextColorForBackground(
                Theme.of(context).primaryColor),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We've sent a verification email to:",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.email,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                "Please check your email and verify your account. We'll automatically redirect you once verified.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser
                      ?.sendEmailVerification();

                  if (!context.mounted) return;

                  Utils.displayDialog(
                    context: context,
                    title: 'Email Resent',
                    content: 'Verification email resent.',
                  );
                },
                child: const Text('Resend verification email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
