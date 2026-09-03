import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Token-driven text field (SIRATI-21). Uses [AppFormStyles] / theme inputs.
class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? semanticLabel;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.semanticLabel,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? label ?? hint,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTouchTarget.min),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTypography.of(context, AppTypography.bodyMd),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
          ),
        ),
      ),
    );
  }
}
