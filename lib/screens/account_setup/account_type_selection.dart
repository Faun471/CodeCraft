import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/widgets/image_button.dart';
import 'package:flutter/material.dart';

class AccountTypeSelection extends StatefulWidget {
  final Map<String, String> userData;

  const AccountTypeSelection({Key? key, required this.userData})
      : super(key: key);

  @override
  _AccountTypeSelectionState createState() => _AccountTypeSelectionState();
}

class _AccountTypeSelectionState extends State<AccountTypeSelection> {
  late ImageRadioButtonController controller = ImageRadioButtonController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              'Select Account Type',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'This action cannot be undone. Please select your account type carefully.\n' +
                  'You will not be able to change this later.\n' +
                  'You can always create a new account with a different account type.',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30),
        ImageRadioButtonGroup(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          controller: controller,
          buttons: [
            ImageRadioButton(
                image:
                    'https://images.pexels.com/photos/6925184/pexels-photo-6925184.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                text: 'Student',
                value: 'student',
                isSelected: true,
                onChanged: null),
            ImageRadioButton(
                image:
                    'https://images.pexels.com/photos/6925184/pexels-photo-6925184.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                text: 'Teacher',
                value: 'teacher',
                isSelected: false,
                onChanged: null),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(
                  futures: <Future>[
                    Auth(DatabaseHelper().auth).registerUser(
                      widget.userData["email"]!,
                      widget.userData["password"]!,
                    )
                  ],
                  onDone: (context, _) async {
                    print('Done');
                    if (DatabaseHelper().auth.currentUser == null) {
                      print('User not logged in');
                      return;
                    }
                    await DatabaseHelper().currentUser.set({
                      'first_name': widget.userData["first_name"]!,
                      'mi': widget.userData["mi"]!,
                      'last_name': widget.userData["last_name"]!,
                      'suffix': widget.userData["suffix"]!,
                      'email': widget.userData["email"]!,
                      'phone_number': widget.userData["phone_number"]!,
                      'account_type': controller.selectedValue,
                      'preferred_color': 'ff9c27b0',
                      'level': 1,
                    }, SetOptions(merge: true));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Body(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
