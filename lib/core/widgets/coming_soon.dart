import 'package:flutter/material.dart';

/// Affiche « [label] — à venir » pour une fonctionnalité pas encore branchée.
void showComingSoon(BuildContext context, String label) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$label — à venir'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
