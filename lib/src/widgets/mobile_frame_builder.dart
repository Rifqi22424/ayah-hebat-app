import 'package:flutter/material.dart';

/// Wraps [child] in a centered, width-constrained column capped at 480 logical
/// pixels. Used on all screens changed by the mobile-ui-update feature so the
/// Flutter web build renders as a mobile-first viewport on wider displays.
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );
  }
}
