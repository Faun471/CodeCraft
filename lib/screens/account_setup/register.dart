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
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildRegisterForm(),
        ),
        _buildOrDivider(context),
        Padding(
          padding: const EdgeInsets.all(20),
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
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: AutoSizeText(
            'Create your account',
            style: AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Or log in with',
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
          _buildNameFields(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  labelText: 'Last Name',
                  icon: Icons.person,
                  controller: lastNameController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: CustomTextField(
                  labelText: 'Suffix',
                  controller: suffixController,
                  isRequired: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            labelText: 'Email',
            icon: Icons.email,
            mode: ValidationMode.email,
            controller: emailController,
          ),
          const SizedBox(height: 10),
          _buildPhoneNumberInput(),
          const SizedBox(height: 10),
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
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: CustomTextField(
            labelText: 'MI',
            controller: miController,
            isRequired: false,
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
      formatInput: true,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '* This field is required';
        }
        return null;
      },
      hintText: 'Phone Number',
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        PasswordTextField(
          labelText: 'Password',
          controller: passwordController,
          focusNode: passwordFocusNode,
          icon: Icons.lock,
          mode: ValidationMode.password,
        ),
        const SizedBox(height: 10),
        PasswordTextField(
          labelText: 'Confirm Password',
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          icon: Icons.lock,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '* This field is required';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          mode: ValidationMode.password,
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
