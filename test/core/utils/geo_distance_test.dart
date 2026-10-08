import 'package:amily/core/utils/geo_distance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('haversineKm : distance nulle pour un même point', () {
    expect(haversineKm(48.8566, 2.3522, 48.8566, 2.3522), 0);
  });

  test('haversineKm : Paris → Lyon ≈ 392 km', () {
    expect(haversineKm(48.8566, 2.3522, 45.7640, 4.8357), closeTo(392, 2));
  });
}
