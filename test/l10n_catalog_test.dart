import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpenc/l10n/generated/app_localizations.dart';

void main() {
  test('Arabic and English catalogs expose contextual financial messages', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(en.generalTitle, 'General');
    expect(ar.generalTitle, 'عام');
    expect(ar.paymentPayTitle('Rent'), 'موعد الدفع: Rent');
    expect(ar.budgetOverspentBody('50', '100'), 'أنفقت 50 من أصل 100.');
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode),
        containsAll(['en', 'ar']));
  });

  testWidgets('Arabic locale uses right-to-left directionality', (tester) async {
    late TextDirection direction;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: (context) {
        direction = Directionality.of(context);
        return Text(AppLocalizations.of(context).settingsTitle);
      }),
    ));
    await tester.pumpAndSettle();
    expect(direction, TextDirection.rtl);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('English locale uses left-to-right directionality', (tester) async {
    late TextDirection direction;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(builder: (context) {
        direction = Directionality.of(context);
        return Text(AppLocalizations.of(context).settingsTitle);
      }),
    ));
    await tester.pumpAndSettle();
    expect(direction, TextDirection.ltr);
    expect(find.text('Settings'), findsOneWidget);
  });
}
