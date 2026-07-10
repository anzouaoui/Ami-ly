import '../../../auth/data/models/parent_profile_model.dart';
import '../../../parent/data/models/child_model.dart';

/// Regroupement d'un parent et de ses enfants pour l'affichage.
class ParentWithChildren {
  const ParentWithChildren({
    required this.parent,
    required this.children,
  });

  final ParentProfileModel parent;
  final List<ChildModel> children;
}
