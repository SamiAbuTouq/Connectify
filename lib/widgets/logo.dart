import 'package:flutter/material.dart';
import 'package:connectify/theme.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Image.asset(
          'assets/images/logo/T-logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
