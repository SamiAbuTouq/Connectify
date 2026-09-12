import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectify/onboarding/onboarding_screens.dart';
import 'package:connectify/theme.dart';

void main() {
  group('OnboardingScreens Tests', () {
    testWidgets('Full flow test: Next, Back, Swipe and Get Started on iPhone SE (375x667)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreens(),
        ),
      );

      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('Welcome to Connectify!'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsNothing);

      // Tap Next -> Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text("Need Help? We've Got You!"), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Tap Back -> Page 1
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Connectify!'), findsOneWidget);
      expect(find.text('Back'), findsNothing);

      // Swipe Left -> Page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text("Need Help? We've Got You!"), findsOneWidget);

      // Swipe Left -> Page 3
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Your Skills, Your Service!'), findsOneWidget);

      // Swipe Right -> Page 2
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.text("Need Help? We've Got You!"), findsOneWidget);

      // Next -> Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Your Skills, Your Service!'), findsOneWidget);

      // Next -> Page 4
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Get Things Done with a Smile!'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    for (final entry in {
      'Compact (320x568)': const Size(320, 568),
      'iPhone 14 (390x844)': const Size(390, 844),
      'Android Standard (412x915)': const Size(412, 915),
      'Tablet (768x1024)': const Size(768, 1024),
    }.entries) {
      testWidgets('Responsive test on ${entry.key}', (WidgetTester tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: AppTheme.lightTheme,
            home: const OnboardingScreens(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome to Connectify!'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);

        // Advance to page 4 to ensure "Get Started" and "Back" render without overflow
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
      });
    }

    testWidgets('Dark theme rendering test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingScreens(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Connectify!'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
