import 'package:flutter/material.dart';

enum ValidationMode { email, none, password }

mixin TextFieldMixin {
  String? defaultValidator(String value, ValidationMode mode) {
    switch (mode) {
      case ValidationMode.email:
        return RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value)
            ? null
            : 'Please enter a valid email';
      case ValidationMode.password:
        {
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
            return 'Password must contain at least one uppercase character';
          }
          if (!RegExp(r'(?=.*?[!@#\$&*~])').hasMatch(value)) {
            return 'Password must contain at least one special character';
          }
        }
      case ValidationMode.none:
        return null;
    }

    return null;
  }
}

class CustomTextField extends StatefulWidget with TextFieldMixin {
  final String labelText;
  final TextEditingController controller;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final ValidationMode mode;
  final bool isRequired;

  CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.icon,
    this.validator,
    this.mode = ValidationMode.none,
    this.isRequired = true,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool isValid;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    isValid = widget.validator != null
        ? widget.validator!(widget.controller.text) == null
        : widget.defaultValidator(widget.controller.text, widget.mode) == null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: 'Enter your ${widget.labelText}',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
      ),
      validator: (value) => widget.validator != null
          ? widget.validator!(value)
          : value!.trim().isEmpty && widget.isRequired
              ? '* This field is required'
              : widget.defaultValidator(value, widget.mode),
    );
  }
}

class PasswordTextField extends StatefulWidget with TextFieldMixin {
  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final ValidationMode mode;
  final bool isRequired;

  PasswordTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.focusNode,
    this.icon,
    this.validator,
    this.mode = ValidationMode.none,
    this.isRequired = true,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _passwordVisible = false;
  late bool isValid;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_focusChanged);

    isValid = widget.validator != null
        ? widget.validator!(widget.controller.text) == null
        : widget.defaultValidator(widget.controller.text, widget.mode) == null;
  }

  void _focusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: !_passwordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.labelText,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: widget.focusNode.hasFocus
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) => widget.validator != null
          ? widget.validator!(value)
          : value!.trim().isEmpty && widget.isRequired
              ? '* This field is required'
              : widget.defaultValidator(value, widget.mode),
    );
  }
}
