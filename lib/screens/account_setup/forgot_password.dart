import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ForgotPasswordPage(),
    );
  }
}

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


//basta sa firebase e2

  Future<void> passwordReset() async {
    try{
        await DatabaseHelper().auth.sendPasswordResetEmail(email: _emailController.text.trim());
        showDialog(
        context: context, 
        builder: (context) {
          return const AlertDialog(
            content: Text("Success! Check Your Email for the Password Reset Link."),
          );
        },
      );   
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return
     Column(
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
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                fillColor: Colors.grey[200],
                filled: true,
              ),
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