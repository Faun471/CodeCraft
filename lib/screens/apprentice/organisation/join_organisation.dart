import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/providers/invitation_provider.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';

class JoinOrganisation extends ConsumerStatefulWidget {
  const JoinOrganisation({super.key});

  @override
  _JoinOrganisationState createState() => _JoinOrganisationState();
}

class _JoinOrganisationState extends ConsumerState<JoinOrganisation> {
  final orgController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Organisation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'You are not part of any organisation.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: CustomTextField(
                labelText: 'Invitation Code',
                controller: orgController,
                mode: ValidationMode.none,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () =>
                  isLoading ? null : _joinOrganisation(context, ref),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Join Organisation',
                      style: TextStyle(
                        color: ThemeUtils.getTextColor(
                            Theme.of(context).primaryColor),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _joinOrganisation(BuildContext context, WidgetRef ref) async {
    if (orgController.text.isEmpty) {
      Utils.displayDialog(
        context: context,
        lottieAsset: 'assets/anim/error.json',
        title: 'Whoops!',
        content: 'Please enter a code',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final dbHelper = DatabaseHelper();

    final invitation = await dbHelper.invitations.doc(orgController.text).get();

    if (!invitation.exists) {
      if (context.mounted) {
        Utils.displayDialog(
          context: context,
          lottieAsset: 'assets/anim/error.json',
          title: 'Whoops!',
          content: 'Invalid code',
        );
      }

      setState(() {
        isLoading = false;
      });
      return;
    }

    final invitationService = ref.read(invitationNotifierProvider.notifier);

    try {
      await invitationService.joinOrgWithCode(orgController.text);

      if (!context.mounted) {
        return;
      }

      Utils.displayDialog(
        context: context,
        lottieAsset: 'assets/anim/congrats.json',
        title: 'Success',
        content:
            'You have successfully sent a request to join the organisation.',
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      Utils.displayDialog(
        context: context,
        lottieAsset: 'assets/anim/error.json',
        title: 'Whoops!',
        content: e.toString(),
      );
    }

    setState(() {
      isLoading = false;
    });
  }
}
