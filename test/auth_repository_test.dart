import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthRepository Tests', () {
    test('signIn returns a UserModel on success', () async {
      const userModel = UserModel(id: '123', email: 'test@example.com');
      when(
        () => mockAuthRepository.signIn(any(), any()),
      ).thenAnswer((_) async => userModel);

      final result = await mockAuthRepository.signIn(
        'test@example.com',
        'password',
      );

      expect(result, isA<UserModel>());
      expect(result?.email, 'test@example.com');
      verify(
        () => mockAuthRepository.signIn('test@example.com', 'password'),
      ).called(1);
    });

    test('signOut is called once', () async {
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async => {});

      await mockAuthRepository.signOut();

      verify(() => mockAuthRepository.signOut()).called(1);
    });
  });
}
