import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/providers/invitation_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Organisation extends ConsumerStatefulWidget {
  const Organisation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrganisationState();
}

class _OrganisationState extends ConsumerState<Organisation> {
  String organisationName = '';
  String organisationDescription = '';
  String organisationMentor = '';
  final orgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!isInOrganisation()) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Organisation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are not part of any organisation.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  onPressed: () async {
                    final dbHelper = DatabaseHelper();
                    final invitation = await dbHelper.invitations
                        .doc(orgController.text)
                        .get();

                    final invitationService =
                        ref.read(invitationNotifierProvider.notifier);

                    if (invitation.exists) {
                      try {
                        await invitationService
                            .joinOrgWithCode(orgController.text);

                        if (context.mounted) {
                          Utils.displayDialog(
                            context: context,
                            lottieAsset: 'assets/anim/congrats.json',
                            title: 'Success',
                            content:
                                'You have successfully sent a request to join the organisation.',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Utils.displayDialog(
                            context: context,
                            lottieAsset: 'assets/anim/error.json',
                            title: 'Whoops!',
                            content: e.toString(),
                          );
                        }
                      }

                      orgController.clear();
                    }
                  },
                  child: const Text('Join Organisation'),
                ),
                const SizedBox(width: 10),
              ],
            )
          ],
        ),
      );
    }

    return FutureBuilder(
      future: fetchOrganisationDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LoadingAnimationWidget.flickr(
            leftDotColor: Theme.of(context).primaryColor,
            rightDotColor: Theme.of(context).colorScheme.secondary,
            size: MediaQuery.of(context).size.width * 0.1,
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Organisation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Here are the details of your organisation.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Organisation Name: $organisationName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Organisation Description: $organisationDescription',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Organisation Mentor: $organisationMentor',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isInOrganisation() {
    final user = ref.watch(appUserNotifierProvider).value;

    if (user!.orgId == null) {
      return false;
    }

    if (user.orgId!.isEmpty) {
      return false;
    }

    if (user.orgId == DatabaseHelper.defaultOrgId) {
      return false;
    }

    return true;
  }

  Future<void> fetchOrganisationDetails() async {
    organisationName = await getOrganisationName();
    organisationDescription = await getOrganisationDescription();
    organisationMentor = await getOrganisationMentor();
  }

  Future<String> getOrganisationName() async {
    final dbHelper = DatabaseHelper();
    final organisationName = await dbHelper.organisations
        .doc(ref.watch(appUserNotifierProvider).value!.orgId ?? '')
        .get();

    return organisationName['orgName'] as String;
  }

  Future<String> getOrganisationDescription() async {
    final dbHelper = DatabaseHelper();
    final organisationDescription = await dbHelper.organisations
        .doc(ref.watch(appUserNotifierProvider).value!.orgId ?? '')
        .get();

    return organisationDescription['orgDescription'] as String;
  }

  Future<String> getOrganisationMentor() async {
    final dbHelper = DatabaseHelper();
    final organisationMentor = await dbHelper.organisations
        .doc(ref.watch(appUserNotifierProvider).value!.orgId ?? '')
        .get();

    final mentorId = organisationMentor['mentorId'] as String;

    final mentor = await dbHelper.users.doc(mentorId).get();

    return '${mentor['firstName']} ${mentor['lastName']}';
  }
}
