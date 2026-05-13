import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/models/address_suggestion.dart';
import '../../core/services/address_autocomplete_service.dart';

/// Champ adresse avec autocomplétion via l'API BAN (data.gouv.fr).
///
/// - Debounce 350 ms avant chaque appel API.
/// - Affiche une liste de suggestions sous le champ.
/// - [onSelected] est appelé quand l'utilisateur choisit une suggestion
///   (fournit le label + lat/lon pour Firestore).
/// - [onClearLocation] est appelé quand l'utilisateur tape manuellement
///   (les coordonnées ne sont plus valides).
class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.onSelected,
    required this.onClearLocation,
  });

  final TextEditingController controller;
  final String label;
  final void Function(AddressSuggestion suggestion) onSelected;
  final VoidCallback onClearLocation;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final _service = AddressAutocompleteService();
  List<AddressSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    widget.onClearLocation();
    _debounce?.cancel();

    if (value.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await _service.searchAddresses(value);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _loading = false;
        });
      }
    });
  }

  void _select(AddressSuggestion suggestion) {
    widget.controller.text = suggestion.label;
    setState(() => _suggestions = []);
    widget.onSelected(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: _onChanged,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.location_on_outlined, size: 20),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _suggestions.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.divider),
                  InkWell(
                    onTap: () => _select(_suggestions[i]),
                    borderRadius: i == 0
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(AppRadii.md),
                            topRight: Radius.circular(AppRadii.md),
                          )
                        : i == _suggestions.length - 1
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(AppRadii.md),
                                bottomRight: Radius.circular(AppRadii.md),
                              )
                            : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _suggestions[i].label,
                              style: AppTextStyles.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
