import 'package:flutter/material.dart';

class KeyboardAwareScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
} 