import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/register.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/widgets/logo_with_background.dart';
import 'package:codecraft/widgets/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late bool isVertical;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.sizeOf(context).aspectRatio < 1.0;

    return Scaffold(
      body: Row(
        children: [
          if (!isVertical) LogoWithBackground(isVertical: isVertical),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isVertical) LogoWithBackground(isVertical: isVertical),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: AutoSizeText(
                      'Welcome Back!',
                      style: AdaptiveTheme.of(context)
                          .theme
                          .textTheme
                          .displayLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(child: LoginForm(), padding: EdgeInsets.all(20)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Or log in with',
                            style: AdaptiveTheme.of(context)
                                .theme
                                .textTheme
                                .bodyLarge,
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
                    child: FilledButton(
                      onPressed: () {
                        Auth(DatabaseHelper().auth).signInWithGoogle().then(
                          (error) {
                            // If the error message is null, then the registration is successful.
                            if (error == null) {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Body();
                              }));
                            } else {
                              // _showErrorDialog(context, error);
                            }
                          },
                        );
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                side: BorderSide(
                                    color: Color.fromARGB(255, 21, 21, 21))),
                          ),
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.white,
                          ),
                          minimumSize: MaterialStateProperty.all(
                              const Size.fromHeight(60))),
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
                    padding: EdgeInsets.all(20),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Form LoginForm() {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
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
                onPressed: () {},
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
              if (_formKey.currentState!.validate()) {
                Auth(DatabaseHelper().auth)
                    .loginUser(emailController.text, passwordController.text)
                    .then(
                  (error) {
                    if (error == null) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const Body();
                      }));
                    } else {
                      Dialogs.materialDialog(
                        context: context,
                        msg: error,
                        title: 'Error',
                        color: Colors.white,
                        lottieBuilder: Lottie.asset(
                          'assets/anim/error.json',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                        dialogWidth: isVertical ? 0.8 : 0.4,
                        actions: [
                          IconsButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'Close',
                            iconData: Icons.close,
                            color: Colors.red,
                            textStyle: TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                        ],
                      );
                    }
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60)),
            child: Text('Log In'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Register()));
            },
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                side: BorderSide(color: Colors.grey)),
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
