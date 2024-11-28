// File: lib/register.dart

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/account_type_selection.dart';
import 'package:codecraft/screens/account_setup/login.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController miController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController suffixController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        Padding(
          padding:
              const EdgeInsets.only(top: 20, bottom: 10, left: 40, right: 40),
          child: AutofillGroup(
            child: _buildRegisterForm(),
          ),
        ),
        _buildOrDivider(context),
        Padding(
          padding: const EdgeInsets.all(40),
          child: _buildGoogleSignInButton(context),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 10),
          child: AutoSizeText(
            'Create your account',
            style: AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _buildSignInLink(context),
        ),
      ],
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Row(
      children: [
        Text(
          'Already a member?',
          style: AdaptiveTheme.of(context).theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 5),
        InkWell(
          child: Text(
            'Log In',
            style:
                AdaptiveTheme.of(context).theme.textTheme.bodyMedium!.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
          ),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AccountSetup(Login())),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Or create an account with',
              style: AdaptiveTheme.of(context).theme.textTheme.bodyMedium,
            ),
          ),
          const Expanded(child: Divider(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return FilledButton(
      onPressed: () async =>
          await ref.watch(authProvider.notifier).signInWithGoogle(),
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            side: BorderSide(color: Colors.black),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(60)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset('assets/images/google.png', width: 30, height: 30),
          const SizedBox(width: 15),
          const Text(
            'Continue with Google',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Form _buildRegisterForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          // _buildNameFields(),
          // Row(
          //   children: [
          //     Expanded(
          //       flex: 2,
          //       child: CustomTextField(
          //         labelText: 'Last Name',
          //         icon: Icons.person,
          //         controller: lastNameController,
          //         textInputAction: TextInputAction.next,
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Expanded(
          //       flex: 1,
          //       child: CustomTextField(
          //         labelText: 'Suffix',
          //         controller: suffixController,
          //         isRequired: false,
          //         textInputAction: TextInputAction.next,
          //       ),
          //     ),
          //   ],
          // ),
          // CustomTextField(
          //   labelText: 'Username',
          //   icon: Icons.person,
          //   controller: displayNameController,
          //   isRequired: false,
          //   textInputAction: TextInputAction.next,
          // ),
          CustomTextField(
            labelText: 'Email',
            icon: Icons.email,
            mode: ValidationMode.email,
            controller: emailController,
            autofillHint: AutofillHints.email,
            textInputAction: TextInputAction.next,
          ),
          // _buildPhoneNumberInput(),
          // const SizedBox(height: 10),
          _buildPasswordFields(),
          _buildCreateAccountButton(),
        ],
      ),
    );
  }

  Row _buildNameFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            icon: Icons.person,
            labelText: 'First Name',
            controller: firstNameController,
            autofillHint: AutofillHints.givenName,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: CustomTextField(
            labelText: 'MI',
            controller: miController,
            isRequired: false,
            autofillHint: AutofillHints.middleName,
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
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
      keyboardAction: TextInputAction.next,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '* This field is required';
        }

        if (value.length != 12) {
          return 'Invalid phone number';
        }
        return null;
      },
      hintText: 'Phone Number',
      autofillHints: const [AutofillHints.telephoneNumber],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        PasswordTextField(
          labelText: 'Password',
          controller: passwordController,
          icon: Icons.lock,
          mode: ValidationMode.password,
          textInputAction: TextInputAction.next,
        ),
        PasswordTextField(
          labelText: 'Confirm Password',
          controller: confirmPasswordController,
          icon: Icons.lock,
          validator: (value) {
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: () => _createAccount(),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ElevatedButton(
        onPressed: _createAccount,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
        ),
        child: const Text('Create Account'),
      ),
    );
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountSetup(
            AccountTypeSelection(
              userData: {
                'firstName': firstNameController.text,
                'mi': miController.text,
                'lastName': lastNameController.text,
                'suffix': suffixController.text,
                'displayName': displayNameController.text,
                'email': emailController.text,
                'phoneNumber': phoneNumberController.text,
                'password': passwordController.text,
              },
            ),
          ),
        ),
      );
    }
  }
}
