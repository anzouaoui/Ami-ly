import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../providers/auth_providers.dart';

/// Longueur minimale d'un mot de passe Firebase.
const kMinPasswordLength = 6;

/// Validateur de champ e-mail des formulaires d'authentification.
String? validateEmail(String? value) =>
    (value == null || !value.contains('@')) ? 'E-mail invalide' : null;

/// Validateur de champ mot de passe des formulaires d'authentification.
String? validatePassword(String? value) =>
    (value == null || value.length < kMinPasswordLength)
        ? 'Min. 6 caractères'
        : null;

/// État commun aux écrans d'authentification : indicateur de chargement,
/// message d'erreur, et exécution d'une action du repository.
mixin AuthFormStateMixin<W extends ConsumerStatefulWidget>
    on ConsumerState<W> {
  bool isLoading = false;
  String? errorMessage;

  /// Lance [action] en affichant le chargement. En cas d'échec, affiche le
  /// message de la [Failure] ; en cas de succès, appelle [onSuccess].
  Future<void> runAuthAction<T>(
    Future<Either<Failure, T>> Function() action, {
    void Function(T value)? onSuccess,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await action();

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        errorMessage = failure.message;
        isLoading = false;
      }),
      (value) {
        setState(() => isLoading = false);
        onSuccess?.call(value);
      },
    );
  }

  /// À appeler dans `build` : dès que le stream émet un utilisateur
  /// connecté, remonte à la racine pour laisser AuthWrapper afficher
  /// ParentShell / AssMatShell.
  void popToRootWhenSignedIn() {
    ref.listen(currentUserProvider, (_, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    });
  }
}
