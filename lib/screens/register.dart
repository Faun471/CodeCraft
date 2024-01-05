import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/user.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:codecraft/screens/modules.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController username = TextEditingController();
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
                TextField(
                  controller: username,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
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
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: TextButton(
                  onPressed: () {},
                  child: const Align(
                    alignment:
                        Alignment.centerRight, // Align the text to the end.
                    child: Text('Forgot Password?'),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                String inputUsername = username.text;
                String inputPassword = password.text;

                if (inputUsername.isEmpty || inputPassword.isEmpty) {
                  // Show some error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please fill in all fields'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Continue with your logic
                  User().setUsername(inputUsername);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FutureBuilder(
                        future: context.read<LevelProvider>().loadState(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.white,
                                size: 200,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const Modules();
                          }
                        },
                      ),
                    ),
                  );
                }
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
                    color: Colors.black,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
                const Text(
                  ' or continue with ',
                  style: TextStyle(
                      fontSize: 15.0, color: Color.fromARGB(255, 87, 87, 87)),
                ),
                Expanded(
                  child: Container(
                    height: 1.0,
                    color: Colors.black,
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
                    onPressed: () {},
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                              side: BorderSide(color: Colors.black12)),
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
                    onPressed: () {},
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
}
