import 'package:flutter/material.dart';
import 'package:logs_mobile_app/shared/validators.dart';

class BWTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? typeHint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValidatorType validatorType; // 👈 NEW
  final String? Function(String?)? validator; // optional override

  const BWTextField({
    super.key,
    required this.controller,
    required this.label,
    this.typeHint,
    this.obscure = false,
    this.keyboardType,
    this.validatorType = ValidatorType.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator ?? _defaultValidator, // if user didn’t pass custom
      decoration: InputDecoration(
        labelText: label,
        hintText: typeHint,
      ),
    );
  }

  /// Selects the validator based on [validatorType]
  String? _defaultValidator(String? value) {
    switch (validatorType) {
      case ValidatorType.email:
        return Validators.emailValidator(value);
      case ValidatorType.phone:
        return Validators.phoneValidator(value);
      case ValidatorType.password:
        return Validators.passwordValidator(value);
      case ValidatorType.none:
        return null; // no validation
    }
  }
}
