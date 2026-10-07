import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_meds/app.dart';
import 'package:my_meds/features/auth/domain/auth_repository.dart';
import 'package:my_meds/features/auth/domain/user_entity.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('MyMedsApp builds without errors', (WidgetTester tester) async {
    final mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.authStateChanges())
        .thenAnswer((_) => Stream<AppUser?>.value(null));
    when(() => mockAuthRepository.currentUser).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MyMedsApp(),
      ),
    );

    // Initial frame pumps MaterialApp and SplashScreen
    expect(find.byType(MyMedsApp), findsOneWidget);
  });
}
