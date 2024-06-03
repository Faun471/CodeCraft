import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/forgot_password.dart';
import 'package:codecraft/screens/apprentice/apprentice_home.dart';
import 'package:codecraft/screens/account_setup/register.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: AutoSizeText(
            'Welcome Back!',
            style: AdaptiveTheme.of(context).theme.textTheme.displayLarge,
          ),
        ),
        const SizedBox(height: 10),
        Padding(padding: const EdgeInsets.all(20), child: loginForm()),
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
            onPressed: () {
              Auth(DatabaseHelper().auth).signInWithGoogle().then(
                (error) {
                  // If the error message is null, then the registration is successful.
                  if (error == null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const Body();
                        },
                      ),
                    );
                  } else {
                    // _showErrorDialog(context, error);
                  }
                },
              );
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

  Form loginForm() {
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
          ),
          const SizedBox(height: 10),
          PasswordTextField(
            labelText: 'Password',
            controller: passwordController,
            focusNode: focusNode,
            icon: Icons.lock,
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Auth(DatabaseHelper().auth)
                    .loginUser(emailController.text, passwordController.text)
                    .then(
                  (error) {
                    if (error == null) {
                      if (!mounted) {
                        return;
                      }

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return LoadingScreen(
                          futures: [
                            Provider.of<AppUser>(context, listen: false)
                                .fetchData()
                          ],
                          onDone: (context, _) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const Body();
                            }));
                          },
                        );
                      }));
                    } else {
                      if (!mounted) {
                        return;
                      }

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
                    }
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60)),
            child: const Text('Log In'),
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
}
