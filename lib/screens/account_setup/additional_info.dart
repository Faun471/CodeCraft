import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/account_type_selection.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final User user;

  const AdditionalInfoScreen({super.key, required this.user});

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final FocusNode phoneNumberFocusNode = FocusNode();

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

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: AutoSizeText(
            'Complete your account setup',
            style: AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
          ),
        ),
      ],
    );
  }

  Form _buildAdditionalInfoForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
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
        onPressed: _proceedToAccountTypeSelection,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
        ),
        child: const Text('Proceed to Account Type Selection'),
      ),
    );
  }

  void _proceedToAccountTypeSelection() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> userData = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phoneNumber': phoneNumberController.text,
        'email': widget.user.email ?? '',
        'mi': '',
        'suffix': '',
        'displayName': '${firstNameController.text} $lastNameController.text}',
        'googleSignIn': 'true',
        'uid': widget.user.uid,
      };

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AccountSetup(AccountTypeSelection(userData: userData)),
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
