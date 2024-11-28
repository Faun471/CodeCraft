import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class OrganizationCard extends ConsumerWidget {
  final Organization organization;

  const OrganizationCard({super.key, required this.organization});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserNotifierProvider).requireValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (constraints.maxWidth < 425)
                  _buildSmallLayout(context, ref, appUser)
                else
                  _buildLargeLayout(context, ref, appUser),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallLayout(
      BuildContext context, WidgetRef ref, AppUser appUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        CachedNetworkImageProvider(organization.imageUrl),
                  ),
                  SizedBox(height: 10),
                  Text(
                    organization.orgName.isEmpty
                        ? 'Organization Name'
                        : organization.orgName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (organization.mentorId ==
                  FirebaseAuth.instance.currentUser!.uid)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconsButton(
                    padding: EdgeInsets.zero,
                    text: 'Edit',
                    iconData: Icons.edit,
                    onPressed: () =>
                        _showEditOrganizationDialog(context, organization, ref),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(organization.orgDescription, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        _buildMentorRow(),
        SizedBox(height: 10),
        _buildInfoRow(Icons.code, 'Code: ${organization.code}'),
        SizedBox(height: 10),
        _buildInfoRow(
            Icons.people, 'Apprentices: ${organization.apprentices.length}'),
        SizedBox(height: 10),
        _buildFooter(context, appUser),
      ],
    );
  }

  Widget _buildLargeLayout(
      BuildContext context, WidgetRef ref, AppUser appUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  CachedNetworkImageProvider(organization.imageUrl),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                organization.orgName.isEmpty
                    ? 'Organization Name'
                    : organization.orgName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (organization.mentorId == FirebaseAuth.instance.currentUser!.uid)
              IconsButton(
                text: 'Edit',
                iconData: Icons.edit,
                onPressed: () =>
                    _showEditOrganizationDialog(context, organization, ref),
              ),
          ],
        ),
        SizedBox(height: 10),
        Text(organization.orgDescription, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        _buildMentorRow(),
        SizedBox(height: 10),
        _buildInfoRow(Icons.code, 'Code: ${organization.code}'),
        SizedBox(height: 10),
        _buildInfoRow(
            Icons.people, 'Apprentices: ${organization.apprentices.length}'),
        SizedBox(height: 10),
        _buildFooter(context, appUser),
      ],
    );
  }

  Widget _buildMentorRow() {
    return Row(
      children: [
        Icon(Icons.person, color: Colors.grey),
        SizedBox(width: 5),
        FutureBuilder(
          future: DatabaseHelper().getUserData(organization.mentorId),
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Mentor: Loading...');
            }
            if (snapshot.hasError) {
              return Text('Mentor: Error loading mentor');
            }
            return Text('Mentor: ${snapshot.data!['displayName']}');
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, AppUser appUser) {
    return Row(
      children: [
        Text(
          'Created At: ${organization.createdAt.split('T').first}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Spacer(),
        if (organization.mentorId != FirebaseAuth.instance.currentUser!.uid ||
            appUser.accountType != "mentor")
          IconsButton(
            text: 'Leave',
            iconData: Icons.exit_to_app,
            onPressed: () {
              Utils.displayDialog(
                context: context,
                title: 'Leave Organization',
                content: 'Are you sure you want to leave this organization?',
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await InvitationService().leaveOrganization(
                          FirebaseAuth.instance.currentUser!.uid);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Leave'),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  void _showEditOrganizationDialog(
      BuildContext context, Organization organization, WidgetRef ref) {
    Uint8List? imageBytes;
    TextEditingController orgNameController =
        TextEditingController(text: organization.orgName);
    TextEditingController orgDescriptionController =
        TextEditingController(text: organization.orgDescription);

    Utils.scrollableMaterialDialog(
      context: context,
      title: 'Edit Organization',
      titleAlign: TextAlign.center,
      titleStyle:
          TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0),
      msg: 'Edit your organization details here.',
      msgStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color, fontSize: 16.0),
      msgAlign: TextAlign.center,
      dialogWidth: MediaQuery.of(context).size.width * 0.8,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      customViewPosition: CustomViewPosition.BEFORE_ACTION,
      customView: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageBytes != null
                              ? MemoryImage(imageBytes!)
                              : CachedNetworkImageProvider(
                                  organization.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () async {
                          imageBytes = await Utils.pickImage(context);
                          if (imageBytes != null) {
                            setState(() {
                              imageBytes = imageBytes;
                            });
                          }
                        },
                        color:
                            Theme.of(context).cardColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Organization Name',
                      prefixIcon: const Icon(Icons.business),
                      hintText: 'Enter organization name',
                    ),
                    controller: orgNameController,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      hintText: 'Enter organization description',
                    ),
                    controller: orgDescriptionController,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        IconsButton(
          iconData: Icons.close,
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        IconsButton(
          iconData: Icons.save,
          text: 'Save',
          onPressed: () async {
            final imageUrl = await uploadImage(imageBytes, organization);

            Organization updatedOrganization = organization.copyWith(
              orgName: orgNameController.text,
              orgDescription: orgDescriptionController.text,
              imageUrl: imageUrl,
            );

            await DatabaseHelper().updateOrganizationDetails(
                ref.watch(appUserNotifierProvider).requireValue.orgId!,
                updatedOrganization);

            if (!context.mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<String?> uploadImage(
      Uint8List? imageBytes, Organization organization) async {
    if (imageBytes == null) {
      return null;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('org_images/${organization.id}.png');
    UploadTask uploadTask = ref.putData(imageBytes);

    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }
}
