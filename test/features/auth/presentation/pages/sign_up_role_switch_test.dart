import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fikraty/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fikraty/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fikraty/features/auth/domain/usecases/request_password_reset.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_in.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_out.dart';
import 'package:fikraty/features/auth/domain/usecases/sign_up.dart';
import 'package:fikraty/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fikraty/features/auth/presentation/pages/sign_up_page.dart';

void main() {
  group('SignUpScreen role switching', () {
    testWidgets('clears entered fields when switching roles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final dataSource = FakeAuthRemoteDataSource();
      final repository = AuthRepositoryImpl(dataSource);
      final authBloc = AuthBloc(
        signIn: SignIn(repository),
        signUp: SignUp(repository),
        requestPasswordReset: RequestPasswordReset(repository),
        signOut: SignOut(repository),
      );
      addTearDown(() => authBloc.close());

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: SignUpScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Default role is Entrepreneur / Founder. Tap Continue.
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: In Details, enter text into the first text form field (Full Name)
      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);

      // Tap Back button in top navigation bar
      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Back to Step 1: Role selection. Tap 'Investor'
      await tester.ensureVisible(find.text('Investor'));
      await tester.tap(find.text('Investor'));
      await tester.pumpAndSettle();

      // Tap Continue to go to Investor Details
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify that 'John Doe' is NOT in any text field in Investor details
      expect(find.text('John Doe'), findsNothing);
    });
  });
}
