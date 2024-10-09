import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/main.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/account_type_selection.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:codecraft/models/app_user_notifier.dart';

class AdditionalInfoScreen extends ConsumerStatefulWidget {
  final User user;

  const AdditionalInfoScreen({super.key, required this.user});

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends ConsumerState<AdditionalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final FocusNode phoneNumberFocusNode = FocusNode();
  Map<String, String> userData = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appUser = ref.read(appUserNotifierProvider).value;
      if (appUser != null) {
        _fillUserData(appUser);

        firstNameController.text = appUser.firstName ?? '';
        lastNameController.text = appUser.lastName ?? '';
        phoneNumberController.text = appUser.phoneNumber ?? '';

        if (!mounted) return;

        if (_userHasCompleteData(appUser) &&
            (userData['accountType'] != 'apprentice' ||
                userData['accountType'] != 'mentor')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountSetup(
                AccountTypeSelection(userData: userData),
              ),
            ),
          );
        }

        String? firstName = userData['firstName'];
        String? lastName = userData['lastName'];
        String? phoneNumber = userData['phoneNumber'];

        if (firstName != null &&
            lastName != null &&
            phoneNumber != null &&
            firstName.isNotEmpty &&
            lastName.isNotEmpty &&
            phoneNumber.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoadingScreen(
                  futures: [getLandingPage(appUser)],
                  onDone: (context, snapshot) async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => snapshot.data[0]!,
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      }
    });
  }

  bool _userHasCompleteData(AppUser appUser) {
    return appUser.firstName != null &&
        appUser.firstName!.isNotEmpty &&
        appUser.lastName != null &&
        appUser.lastName!.isNotEmpty &&
        appUser.phoneNumber != null &&
        appUser.phoneNumber!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildAdditionalInfoForm(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _fillUserData(AppUser appUser) {
    userData = {
      'firstName': appUser.firstName ?? '',
      'lastName': appUser.lastName ?? '',
      'phoneNumber': appUser.phoneNumber ?? '',
      'email': widget.user.email ?? '',
      'mi': appUser.mi ?? '',
      'suffix': appUser.suffix ?? '',
      'displayName': appUser.displayName ??
          widget.user.displayName ??
          (('${appUser.firstName} ${appUser.lastName}').trim().isEmpty
              ? ''
              : '${appUser.firstName} ${appUser.lastName}'),
      'uid': widget.user.uid,
      'accountType': appUser.accountType ?? '',
    };

    firstNameController.text = appUser.firstName ?? '';
    lastNameController.text = appUser.lastName ?? '';
    phoneNumberController.text = appUser.phoneNumber ?? '';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: AutoSizeText(
        'Complete your account setup',
        style: AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
      ),
    );
  }

  Form _buildAdditionalInfoForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          Expanded(
            child: CustomTextField(
              labelText: 'Display Name',
              icon: Icons.person,
              controller: displayNameController,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'First Name',
                  icon: Icons.person,
                  controller: firstNameController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  labelText: 'Last Name',
                  icon: Icons.person,
                  controller: lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildPhoneNumberInput(),
          const SizedBox(height: 10),
          _buildProceedButton(),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberInput() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {},
      maxLength: 12,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        useBottomSheetSafeArea: true,
        setSelectorButtonAsPrefixIcon: true,
        leadingPadding: 20,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      selectorTextStyle: TextStyle(
        color: AdaptiveTheme.of(context).theme.textTheme.bodyMedium!.color,
      ),
      initialValue: PhoneNumber(dialCode: "+63", isoCode: "PH"),
      textFieldController: phoneNumberController,
      formatInput: true,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      focusNode: phoneNumberFocusNode,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '* This field is required';
        }
        return null;
      },
      hintText: 'Phone Number',
    );
  }

  Widget _buildProceedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ElevatedButton(
        onPressed: () async {
          await _proceedToAccountTypeSelection();
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
        ),
        child: const Text('Proceed to Account Type Selection'),
      ),
    );
  }

  Future<void> _proceedToAccountTypeSelection() async {
    if (_formKey.currentState!.validate()) {
      userData = {
        ...userData,
        'displayName': displayNameController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phoneNumber': phoneNumberController.text,
        'email': widget.user.email ?? '',
        'uid': widget.user.uid,
        'googleSignIn': 'true',
      };

      if (!mounted) return;

      String accountType = userData['accountType'] ?? '';
      if (accountType.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountSetup(
              AccountTypeSelection(userData: userData),
            ),
          ),
        );
        return;
      }

      final appUserNotifer = ref.read(appUserNotifierProvider.notifier);
      appUserNotifer.updateData(userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(
            futures: [getLandingPage(ref.read(appUserNotifierProvider).value!)],
            onDone: (context, snapshot) async {
              if (snapshot.data[0] == null) {
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => snapshot.data[0]!,
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    phoneNumberFocusNode.dispose();
    super.dispose();
  }
}
