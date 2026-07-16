import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:amily/core/errors/failures.dart';
import 'package:amily/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:amily/features/video_call/domain/usecases/join_call.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}

void main() {
  late MockVideoCallRepository mockRepository;
  late JoinCall useCase;

  setUp(() {
    mockRepository = MockVideoCallRepository();
    useCase = JoinCall(mockRepository);
  });

  test('joinCall retourne Right(null) en cas de succès', () async {
    when(() => mockRepository.acceptCall('call-1'))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase('call-1');

    expect(result, const Right(null));
    verify(() => mockRepository.acceptCall('call-1')).called(1);
  });

  test('joinCall retourne un Failure en cas d\'erreur', () async {
    when(() => mockRepository.acceptCall('call-1'))
        .thenAnswer((_) async => const Left(FirestoreFailure('Erreur')));

    final result = await useCase('call-1');

    expect(result, isA<Left>());
  });
}
