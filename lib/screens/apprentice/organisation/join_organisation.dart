import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/providers/invitation_provider.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';

class JoinOrganization extends ConsumerStatefulWidget {
  const JoinOrganization({super.key});

  @override
  _JoinOrganizationState createState() => _JoinOrganizationState();
}

class _JoinOrganizationState extends ConsumerState<JoinOrganization> {
  final orgController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Organization',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'You are not part of any organization.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                labelText: 'Invitation Code',
                controller: orgController,
                mode: ValidationMode.none,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () =>
                    isLoading ? null : _joinOrganization(context, ref),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : AutoSizeText(
                        'Join Organization',
                        style: TextStyle(
                          color: ThemeUtils.getTextColorForBackground(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        maxLines: 1,
                        minFontSize: 12,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _joinOrganization(BuildContext context, WidgetRef ref) async {
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
            'You have successfully sent a request to join the organization.',
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
