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
        return _passwordValidator(value);
      case ValidationMode.none:
        return null;
    }
  }

  String? _passwordValidator(String value) {
    final requirements = _getPasswordRequirements(value);
    return requirements.isEmpty
        ? null
        : 'Your password must have ${requirements.join(', ')}';
  }

  List<String> _getPasswordRequirements(String value) {
    final requirements = <String>[];
    if (value.length < 8) {
      requirements.add('at least 8 characters');
    }
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
      requirements.add('one uppercase character');
    }
    if (!RegExp(r'(?=.*?[!@#\$&*~\?:;$\+\-\*\-\/\_])').hasMatch(value)) {
      requirements.add('one special character');
    }
    if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
      requirements.add('one number');
    }
    return requirements;
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
  final String? autofillHint;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;

  CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.initialValue,
    this.icon,
    this.validator,
    this.mode = ValidationMode.none,
    this.isRequired = true,
    this.autofillHint,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          autofillHints:
              widget.autofillHint != null ? [widget.autofillHint!] : null,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            helperText: '',
            labelText:
                '${widget.labelText}${widget.isRequired && widget.controller.text.isEmpty ? ' (Required)' : ''}',
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
          onFieldSubmitted: (value) {
            if (widget.textInputAction == TextInputAction.done &&
                widget.onFieldSubmitted != null) {
              FocusScope.of(context).unfocus();
              widget.onFieldSubmitted!();
            }
          },
        ),
      ],
    );
  }
}

class PasswordTextField extends StatefulWidget with TextFieldMixin {
  final String labelText;
  final TextEditingController controller;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final ValidationMode mode;
  final bool isRequired;
  final String? autofillHints;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;

  PasswordTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.icon,
    this.validator,
    this.mode = ValidationMode.none,
    this.isRequired = true,
    this.autofillHints,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
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
    widget.controller.addListener(_onTextChanged);

    isValid = widget.validator != null
        ? widget.validator!(widget.controller.text) == null
        : widget.defaultValidator(widget.controller.text, widget.mode) == null;
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          obscureText: !_passwordVisible,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: widget.textInputAction,
          autofillHints:
              widget.autofillHints != null ? [widget.autofillHints!] : null,
          decoration: InputDecoration(
            helper: widget.controller.text.isNotEmpty &&
                    widget.mode == ValidationMode.password
                ? _buildPasswordRequirements()
                : const SizedBox(height: 10),
            border: const OutlineInputBorder(),
            labelText:
                '${widget.labelText}${widget.isRequired && widget.controller.text.isEmpty ? ' (Required)' : ''}',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          validator: (value) => widget.validator != null
              ? widget.validator!(value)
              : value!.trim().isEmpty && widget.isRequired
                  ? '* This field is required'
                  : widget.defaultValidator(value, widget.mode),
          onFieldSubmitted: (value) {
            if (widget.textInputAction == TextInputAction.done &&
                widget.onFieldSubmitted != null) {
              FocusScope.of(context).unfocus();
              widget.onFieldSubmitted!();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final value = widget.controller.text;
    final requirements = widget._getPasswordRequirements(value);

    return requirements.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Your password must have ${requirements.join(', ')}',
              style: TextStyle(
                color: requirements.isEmpty ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox(height: 10);
  }
}
