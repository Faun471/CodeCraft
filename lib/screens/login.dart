import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/modules.dart';
import 'package:codecraft/screens/register.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: const Text(
              'Welcome Back!',
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
                  controller: password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  scribbleEnabled: false,
                  obscuringCharacter: '●',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 10),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const Register();
                      }),
                    );
                  },
                  child: const Align(
                    alignment:
                        Alignment.centerRight, // Align the text to the end.
                    child: Text('Don\'t have an account? Sign up here!'),
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

                if (inputEmail.isEmpty || inputPassword.isEmpty) {
                  // Check if the username or password is empty.
                  _showErrorDialog(context, 'Please fill in all the fields.');
                  return;
                }

                await Auth(DatabaseHelper().auth)
                    .loginUser(inputEmail, inputPassword)
                    .then(
                  (error) {
                    if (error == null) {
                      // If the error message is null, then the login is successful.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Modules();
                          },
                        ),
                      );
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
                        (error) {
                          // If the error message is null, then the registration is successful.
                          if (error == null) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const Modules();
                            }));
                          } else {
                            _showErrorDialog(context, error);
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
                        Text('Continue with Google',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 17, 17, 17))),
                      ],
                    )),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: FilledButton(
                    onPressed: () {
                      Auth(DatabaseHelper().auth).signInWithFacebook().then(
                        (error) {
                          // If the error message is null, then the registration is successful.
                          if (error == null) {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return const Modules();
                            }));
                          } else {
                            _showErrorDialog(context, error);
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
                                  color: Color.fromARGB(31, 141, 98, 98))),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) =>
                                const Color.fromARGB(255, 255, 255, 255)),
                        minimumSize: MaterialStateProperty.all(
                            const Size.fromHeight(60))),
                    child: const Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/facebook.png'),
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 15),
                        Text('Continue with Facebook',
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 17, 17, 17))),
                      ],
                    )),
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
          : const Color.fromARGB(255, 40, 35, 35),
    );
  }
}
