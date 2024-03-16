import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/login.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  late TextEditingController email, password, confirmPassword;
  late FocusNode passwordFocusNode, confirmPasswordFocusNode;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    email = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    passwordFocusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
    confirmPasswordFocusNode = FocusNode()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: const Text(
              'Create an account!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Username field
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                //Password field
                TextField(
                  focusNode: passwordFocusNode,
                  controller: password,
                  obscureText: !_passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  scribbleEnabled: false,
                  obscuringCharacter: '●',
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: passwordFocusNode.hasFocus
                        ? IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _passwordVisible = !_passwordVisible;
                                },
                              );
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                //Confirm password field
                TextField(
                  focusNode: confirmPasswordFocusNode,
                  controller: confirmPassword,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  scribbleEnabled: false,
                  obscuringCharacter: '●',
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: confirmPasswordFocusNode.hasFocus
                        ? IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                },
                              );
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ));
                  },
                  child: const Align(
                    alignment:
                        Alignment.centerRight, // Align the text to the end.
                    child: Text('Already have an account? Sign in!'),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ElevatedButton(
              onPressed: () async {
                String inputEmail = email.text;
                String inputPassword = password.text;

                if (inputEmail.isEmpty ||
                    inputPassword.isEmpty ||
                    confirmPassword.text.isEmpty) {
                  // Check if the username or password is empty.
                  _showErrorDialog(context, 'Please fill in all the fields.');
                  return;
                }

                if (!Auth.isEmailValid(inputEmail)) {
                  // Check if the email is valid.
                  _showErrorDialog(context, 'Please enter a valid email.');
                  return;
                }

                if (inputPassword != confirmPassword.text) {
                  // Check if the password and confirm password is the same.
                  _showErrorDialog(context, 'Passwords do not match.');
                  return;
                }

                if (!Auth.isPasswordValid(password.text)) {
                  // Check if the password is valid.
                  _showErrorDialog(context,
                      'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.');
                  return;
                }

                await Auth(DatabaseHelper().auth)
                    .registerUser(inputEmail, inputPassword)
                    .then(
                  (message) {
                    // If the error message is null, then the registration is successful.
                    if (message == 'success') {
                      Dialogs.bottomMaterialDialog(
                        context: context,
                        title: 'Account Created!',
                        titleStyle: AdaptiveTheme.of(context).brightness ==
                                Brightness.light
                            ? const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 21, 21, 21),
                              )
                            : const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        msg: 'Your account has been created successfully!',
                        msgStyle: AdaptiveTheme.of(context).brightness ==
                                Brightness.light
                            ? const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 21, 21, 21),
                              )
                            : const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                        color: AdaptiveTheme.of(context).brightness ==
                                Brightness.light
                            ? Colors.white
                            : const Color.fromARGB(255, 21, 21, 21),
                        lottieBuilder: Lottie.asset(
                          'assets/anim/congrats.json',
                          width: 75,
                          height: 75,
                          fit: BoxFit.contain,
                          repeat: false,
                        ),
                        onClose: (value) => Navigator.of(context).pop(),
                        actions: [
                          IconsButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Body();
                                  },
                                ),
                              );
                            },
                            text: 'Okay!',
                            color: const Color.fromARGB(255, 17, 172, 77),
                            iconData: Icons.check_circle,
                            textStyle: const TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                        ],
                      );

                      return;
                    }
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60)),
              child: const AutoSizeText('Submit', minFontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1.0,
                    color:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? const Color.fromARGB(255, 21, 21, 21)
                            : const Color.fromARGB(255, 255, 255, 255),
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
                Text(
                  ' or continue with ',
                  style: TextStyle(
                      fontSize: 15.0,
                      color: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? const Color.fromARGB(212, 21, 21, 21)
                          : const Color.fromARGB(212, 255, 255, 255)),
                ),
                Expanded(
                  child: Container(
                    height: 1.0,
                    color:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? const Color.fromARGB(255, 21, 21, 21)
                            : const Color.fromARGB(255, 255, 255, 255),
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FilledButton(
                    onPressed: () {
                      Auth(DatabaseHelper().auth).signInWithGoogle().then(
                        (message) {
                          if (message == null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Body();
                                },
                              ),
                            );
                            return;
                          }
                          _showErrorDialog(context, message.toString());
                        },
                      );
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
                        const Size.fromHeight(60),
                      ),
                    ),
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
                    )),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FilledButton(
                  onPressed: () {
                    Auth(DatabaseHelper().auth).signInWithFacebook().then(
                      (message) {
                        if (message == null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Body();
                              },
                            ),
                          );
                          return;
                        }
                        _showErrorDialog(context, message.toString());
                      },
                    );
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            side: BorderSide(
                                color: Color.fromARGB(31, 141, 98, 98))),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => const Color.fromARGB(255, 255, 255, 255)),
                      minimumSize:
                          MaterialStateProperty.all(const Size.fromHeight(60))),
                  child: const Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/images/facebook.png'),
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Continue with Facebook',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromARGB(255, 17, 17, 17),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;

    Dialogs.materialDialog(
      context: context,
      msg: message,
      title: 'Error',
      lottieBuilder: Lottie.asset(
        'assets/anim/error.json',
        width: 75,
        height: 75,
        fit: BoxFit.contain,
        repeat: false,
      ),
      titleStyle: AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
      msgStyle: AdaptiveTheme.of(context).theme.textTheme.displaySmall!,
      color: AdaptiveTheme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color.fromARGB(255, 21, 21, 21),
    );
  }
}
