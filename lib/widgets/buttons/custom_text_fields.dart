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
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
            return 'Password must contain at least one special character';
          }
          if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
            return 'Password must contain at least one number';
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
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final ValidationMode mode;
  final bool isRequired;

  CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.initialValue,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: widget.initialValue,
          controller: widget.controller,
          decoration: InputDecoration(
            labelText:
                '${widget.labelText}${widget.isRequired ? ' (Required)' : ''}',
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
        ),
        if (widget.mode == ValidationMode.password)
          _buildPasswordRequirements(),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final value = widget.controller.text;
    final requirements = [
      if (value.length < 8) 'at least 8 characters',
      if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) 'one uppercase character',
      if (!RegExp(r'(?=.*?[!@#\$&*~\?:;$\+\-\*\-\/])').hasMatch(value))
        'one special character',
      if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) 'one number',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        requirements.isEmpty
            ? 'Your password meets all requirements'
            : 'Your password must have ${requirements.join(', ')}',
        style: TextStyle(
          color: requirements.isEmpty ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
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
    widget.controller.addListener(_onTextChanged);

    isValid = widget.validator != null
        ? widget.validator!(widget.controller.text) == null
        : widget.defaultValidator(widget.controller.text, widget.mode) == null;
  }

  void _focusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusChanged);
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: widget.focusNode,
          controller: widget.controller,
          obscureText: !_passwordVisible,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText:
                '${widget.labelText}${widget.isRequired ? ' (Required)' : ''}',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: widget.focusNode.hasFocus
                ? IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
        ),
        if (widget.mode == ValidationMode.password)
          _buildPasswordRequirements(),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final value = widget.controller.text;
    final requirements = [
      if (value.length < 8) 'at least 8 characters',
      if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) 'one uppercase character',
      if (!RegExp(r'(?=.*?[!@#\$&*~\?:;$\+\-\*\-\/])').hasMatch(value))
        'one special character',
      if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) 'one number',
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        requirements.isEmpty
            ? 'Your password meets all requirements'
            : 'Your password must have ${requirements.join(', ')}',
        style: TextStyle(
          color: requirements.isEmpty ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }
}
