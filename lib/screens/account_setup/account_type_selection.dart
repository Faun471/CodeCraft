import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/account_setup/email_verification_screen.dart';
import 'package:codecraft/screens/apprentice/apprentice_home.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/mentor/mentor_home.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/image_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountTypeSelection extends ConsumerStatefulWidget {
  final Map<String, String> userData;

  const AccountTypeSelection({super.key, required this.userData});

  @override
  _AccountTypeSelectionState createState() => _AccountTypeSelectionState();
}

class _AccountTypeSelectionState extends ConsumerState<AccountTypeSelection> {
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
              'This action cannot be undone. Please select your account type carefully.\nYou will not be able to change this later.\nYou can always create a new account with a different account type.',
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
                  'https://images.pexels.com/photos/4144100/pexels-photo-4144100.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
              text: 'Apprentice',
              value: 'apprentice',
              isSelected: true,
              onChanged: (_) {},
            ),
            ImageRadioButton(
              image:
                  'https://images.pexels.com/photos/6925184/pexels-photo-6925184.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
              text: 'Mentor',
              value: 'mentor',
              isSelected: false,
              onChanged: (_) {},
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    Utils.displayDialog(
        context: context,
        title: 'Are you sure?',
        content:
            'This action cannot be undone.\nYou will not be able to change this later.\nYou can always create a new account with a different account type.',
        lottieAsset: 'assets/anim/question.json',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            child: const Text('Submit'),
          ),
        ]);
  }

  Future<void> _submit() async {
    widget.userData['accountType'] = controller.selectedValue!;

    if (widget.userData['googleSignIn'] == 'true') {
      String uid = widget.userData['uid']!;
      String accountType = controller.selectedValue ?? 'apprentice';

      String orgId = accountType == 'mentor'
          ? await DatabaseHelper().createOrganization(uid)
          : DatabaseHelper.defaultOrgId;

      await DatabaseHelper()
          .createUser(uid, widget.userData, accountType, orgId);
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          futures: [
            ref.watch(authProvider.notifier).registerUser(
                  widget.userData,
                  controller.selectedValue!,
                )
          ],
          onDone: (context, _) async {
            if (ref.watch(authProvider).value!.user == null) {
              return;
            }

            await ref.watch(appUserNotifierProvider.future);

            if (!context.mounted) return;

            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null && !currentUser.emailVerified) {
              await currentUser.sendEmailVerification();

              if (!context.mounted) {
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmailVerifScreen(email: currentUser.email!),
                ),
              );
            } else {
              _navigateToHome();
            }
          },
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (controller.selectedValue == 'mentor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MentorHome(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ApprenticeHome(),
        ),
      );
    }
  }
}
