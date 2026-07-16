import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:amily/core/errors/failures.dart';
import 'package:amily/features/video_call/domain/entities/call.dart';
import 'package:amily/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:amily/features/video_call/domain/usecases/start_call.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}

void main() {
  late MockVideoCallRepository mockRepository;
  late StartCall useCase;

  setUp(() {
    mockRepository = MockVideoCallRepository();
    useCase = StartCall(mockRepository);
  });

  final tCall = Call(
    id: 'call-1',
    channelName: 'channel-1',
    callerId: 'caller-1',
    calleeId: 'callee-1',
    callerName: 'Parent',
    calleeName: 'Assmat',
    status: CallStatus.ringing,
    createdAt: DateTime(2026),
  );

  test('startCall retourne un Call en cas de succès', () async {
    when(() => mockRepository.startCall(
          callerId: any(named: 'callerId'),
          calleeId: any(named: 'calleeId'),
          callerName: any(named: 'callerName'),
          calleeName: any(named: 'calleeName'),
        )).thenAnswer((_) async => Right(tCall));

    final result = await useCase.call(
      callerId: 'caller-1',
      calleeId: 'callee-1',
      callerName: 'Parent',
      calleeName: 'Assmat',
    );

    expect(result, Right(tCall));
    verify(() => mockRepository.startCall(
          callerId: 'caller-1',
          calleeId: 'callee-1',
          callerName: 'Parent',
          calleeName: 'Assmat',
        )).called(1);
  });

  test('startCall retourne un Failure en cas d\'erreur', () async {
    when(() => mockRepository.startCall(
          callerId: any(named: 'callerId'),
          calleeId: any(named: 'calleeId'),
          callerName: any(named: 'callerName'),
          calleeName: any(named: 'calleeName'),
        )).thenAnswer((_) async => const Left(FirestoreFailure('Erreur')));

    final result = await useCase.call(
      callerId: 'caller-1',
      calleeId: 'callee-1',
      callerName: 'Parent',
      calleeName: 'Assmat',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure, isA<FirestoreFailure>()),
      (_) => fail(' aurait dû retourner une erreur'),
    );
  });
}
