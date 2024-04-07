import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/widgets/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:codecraft/screens/login.dart';
import 'package:codecraft/widgets/logo_with_background.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RegisterBody(),
    );
  }
}

class RegisterBody extends StatefulWidget {
  const RegisterBody({Key? key}) : super(key: key);

  @override
  _RegisterBodyState createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  late bool isVertical;
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

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1.0;

    return Row(
      children: [
        if (!isVertical) LogoWithBackground(isVertical: isVertical),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isVertical) LogoWithBackground(isVertical: isVertical),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: AutoSizeText('Create your account',
                      style: AdaptiveTheme.of(context)
                          .theme
                          .textTheme
                          .displayLarge!),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSignInLink(context),
                ),
                const SizedBox(height: 10),
                Padding(child: RegisterForm(), padding: EdgeInsets.all(20)),
                Padding(
                    child: _buildOrDivider(context),
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 20)),
                Padding(
                  child: FilledButton(
                    onPressed: _signInWithGoogle,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.white,
                      ),
                      minimumSize:
                          MaterialStateProperty.all(const Size.fromHeight(60)),
                    ),
                    child: _buildGoogleSignInText(),
                  ),
                  padding: const EdgeInsets.all(20),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
            MaterialPageRoute(builder: (context) => Login()),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Or log in with',
            style: AdaptiveTheme.of(context).theme.textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInText() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Image.asset(
          'assets/images/google.png',
          width: 30,
          height: 30,
        ),
        SizedBox(width: 15),
        Text(
          'Continue with Google',
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }

  void _signInWithGoogle() {
    Auth(DatabaseHelper().auth).signInWithGoogle().then(
      (error) {
        if (error == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Body()));
        } else {
          // Handle error
        }
      },
    );
  }

  Form RegisterForm() {
    final _formKey = GlobalKey<FormState>();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  icon: Icons.person,
                  labelText: 'First Name',
                  controller: firstNameController,
                ),
                flex: 3,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  labelText: 'MI',
                  isRequired: false,
                  controller: miController,
                ),
                flex: 1,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: CustomTextField(
                    labelText: 'Last Name',
                    icon: Icons.person,
                    controller: lastNameController,
                  ),
                  flex: 3),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  labelText: 'Suffix',
                  isRequired: false,
                  controller: suffixController,
                ),
                flex: 1,
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
          InternationalPhoneNumberInput(
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
              color:
                  AdaptiveTheme.of(context).theme.textTheme.bodyMedium!.color,
            ),
            initialValue: PhoneNumber(
              dialCode: "+63",
              isoCode: "PH",
            ),
            textFieldController: phoneNumberController,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '* This field is required';
              }

              return null;
            },
            hintText: 'Phone Number',
          ),
          const SizedBox(height: 10),
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final result = await Auth(DatabaseHelper().auth).registerUser(
                    emailController.text,
                    passwordController.text,
                  );

                  if (result == 'success') {
                    DatabaseHelper().currentUser.set({
                      'first_name': firstNameController.text,
                      'mi': miController.text,
                      'last_name': lastNameController.text,
                      'suffix': suffixController.text,
                      'email': emailController.text,
                      'phone_number': phoneNumberController.text,
                    }, SetOptions(merge: true)).whenComplete(
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Body(),
                        ),
                      ),
                    );
                  } else {
                    Dialogs.materialDialog(
                      context: context,
                      title: 'Error',
                      msg: result,
                      lottieBuilder: Lottie.asset('assets/anim/error.json'),
                      dialogWidth: MediaQuery.of(context).size.width * 0.5,
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        )
                      ],
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              child: Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}
