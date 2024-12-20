import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/forgot_password.dart';
import 'package:codecraft/screens/account_setup/register.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Center(
            child: AutoSizeText(
              'Ready to Code?',
              style: AdaptiveTheme.of(context).theme.textTheme.displayLarge,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20),
          child: AutofillGroup(
            child: _buildLoginForm(),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Or log in with',
                  style: AdaptiveTheme.of(context).theme.textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: FilledButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signInWithGoogle();
            },
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      side: BorderSide(color: Color.fromARGB(255, 21, 21, 21))),
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.white,
                ),
                minimumSize:
                    WidgetStateProperty.all(const Size.fromHeight(60))),
            child: const Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/google.png'),
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 15),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 17, 17, 17),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Form _buildLoginForm() {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          CustomTextField(
            labelText: 'Email',
            icon: Icons.email,
            controller: emailController,
            autofillHint: AutofillHints.email,
          ),
          PasswordTextField(
            labelText: 'Password',
            controller: passwordController,
            icon: Icons.lock,
            autofillHints: AutofillHints.password,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: () {
              if (_isLoading) return;
              _login(formKey, context);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AccountSetup(ForgotPasswordPage());
                  }));
                },
                child: Text(
                  'Forgot Password?',
                  style: AdaptiveTheme.of(context)
                      .theme
                      .textTheme
                      .labelLarge!
                      .copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                _isLoading ? null : () async => await _login(formKey, context),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60)),
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Log In'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountSetup(Register())));
            },
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                side: const BorderSide(color: Colors.grey)),
            child: Text(
              'Create Account',
              style: AdaptiveTheme.of(context).theme.textTheme.labelLarge,
            ),
          )
        ],
      ),
    );
  }

  Future<void> _login(
      GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await ref
          .watch(authProvider.notifier)
          .loginUser(
            emailController.text,
            passwordController.text,
          )
          .then(
        (error) async {
          if (error != null && mounted) {
            if (!context.mounted) return;
            Utils.displayDialog(
              context: context,
              title: 'Error',
              content: error,
              buttonText: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
              lottieAsset: 'assets/anim/error.json',
            );

            setState(() {
              _isLoading = false;
            });

            return;
          }

          // final appUser = await ref.refresh(appUserNotifierProvider.future);

          // final landingPage = await getLandingPage(appUser);

          // navigatorKey.currentState!.pushReplacement((MaterialPageRoute(
          //   builder: (context) => landingPage,
          // )));
        },
      );
    }
  }
}
