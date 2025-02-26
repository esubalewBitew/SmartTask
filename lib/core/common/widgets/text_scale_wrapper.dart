import 'package:flutter/material.dart';

class TextScaleWrapper extends StatelessWidget {

  const TextScaleWrapper({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: child,
    );
  }
}
