import 'dart:convert';
import 'dart:io';

import '../models/address_suggestion.dart';

/// Autocomplétion d'adresses françaises via l'API BAN (data.gouv.fr).
///
/// Gratuite, sans clé API, précise sur le territoire français.
/// Endpoint : https://api-adresse.data.gouv.fr/search/
class AddressAutocompleteService {
  static const _baseUrl = 'api-adresse.data.gouv.fr';
  static const _timeout = Duration(seconds: 5);

  Future<List<AddressSuggestion>> searchAddresses(String query) async {
    if (query.trim().length < 3) return [];

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = _timeout;
      final uri = Uri.https(_baseUrl, '/search/', {
        'q': query.trim(),
        'limit': '6',
        'autocomplete': '1',
      });
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) return [];

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>? ?? [];

      return features.map((f) {
        final props = f['properties'] as Map<String, dynamic>;
        final coords = f['geometry']['coordinates'] as List<dynamic>;
        return AddressSuggestion(
          label: props['label'] as String? ?? '',
          lon: (coords[0] as num).toDouble(),
          lat: (coords[1] as num).toDouble(),
        );
      }).where((s) => s.label.isNotEmpty).toList();
    } catch (_) {
      return [];
    } finally {
      client?.close();
    }
  }
}
