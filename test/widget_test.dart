import 'package:agri_society/app.dart';
import 'package:agri_society/core/catalog.dart';
import 'package:agri_society/core/theme.dart';
import 'package:agri_society/l10n/strings.dart';
import 'package:agri_society/models/product.dart';
import 'package:agri_society/screens/auth/language_screen.dart';
import 'package:agri_society/services/auth_service.dart';
import 'package:agri_society/services/pincode_service.dart';
import 'package:agri_society/state/language_controller.dart';
import 'package:agri_society/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Product _product({String en = 'Tomato', String te = 'టమాటా'}) => Product(
      sellerId: 's1',
      sellerName: 'Ramu',
      sellerPhone: '9876543210',
      category: 'vegetables',
      cropKey: 'tomato',
      nameEn: en,
      nameTe: te,
      unit: 'kg',
      price: 45,
      quantity: 2.5,
      pincode: '522001',
    );

void main() {
  group('Pincode', () {
    test('validates 6-digit Indian pincodes', () {
      expect(PincodeService.isValid('522001'), isTrue);
      expect(PincodeService.isValid('022001'), isFalse);
      expect(PincodeService.isValid('52200'), isFalse);
      expect(PincodeService.isValid('52200a'), isFalse);
    });

    test('parses India Post API success response', () {
      const body = '[{"Message":"Number of pincode(s) found:2","Status":"Success",'
          '"PostOffice":[{"Name":"Guntur","District":"Guntur","State":"Andhra Pradesh"},'
          '{"Name":"Brodipet","District":"Guntur","State":"Andhra Pradesh"}]}]';
      final r = PincodeService.parse(body);
      expect(r.status, PincodeLookupStatus.found);
      expect(r.places.length, 2);
      expect(r.places.first.district, 'Guntur');
      expect(r.places.first.state, 'Andhra Pradesh');
    });

    test('parses not-found and garbage responses', () {
      expect(PincodeService.parse('[{"Message":"No records found","Status":"Error","PostOffice":null}]').status,
          PincodeLookupStatus.notFound);
      expect(PincodeService.parse('not json').status, PincodeLookupStatus.failed);
    });
  });

  group('Mobile + PIN login', () {
    test('normalizes and validates mobile numbers', () {
      expect(AuthService.normalizeMobile('+91 98765 43210'), '9876543210');
      expect(AuthService.normalizeMobile('09876543210'), '9876543210');
      expect(AuthService.isValidMobile('9876543210'), isTrue);
      expect(AuthService.isValidMobile('1234567890'), isFalse);
      expect(AuthService.isValidMobile('98765'), isFalse);
    });

    test('maps mobile to the same auth email however it is typed', () {
      expect(AuthService.emailFor('+91 9876543210'), AuthService.emailFor('9876543210'));
    });

    test('PIN must be exactly 6 digits', () {
      expect(AuthService.isValidPin('123456'), isTrue);
      expect(AuthService.isValidPin('12345'), isFalse);
      expect(AuthService.isValidPin('12345a'), isFalse);
    });
  });

  group('Catalog', () {
    test('crop keys are unique and every crop has a known category', () {
      final keys = Catalog.crops.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length);
      final cats = Catalog.categories.map((c) => c.key).toSet();
      for (final c in Catalog.crops) {
        expect(cats, contains(c.category), reason: c.key);
        expect(Catalog.units, contains(c.unit), reason: c.key);
        expect(c.te, isNotEmpty, reason: c.key);
      }
    });

    test('every category has crops', () {
      for (final c in Catalog.categories) {
        expect(Catalog.cropsIn(c.key), isNotEmpty, reason: c.key);
      }
    });
  });

  group('Product', () {
    test('shows name in the chosen language with fallback', () {
      expect(_product().displayName(true), 'టమాటా');
      expect(_product().displayName(false), 'Tomato');
      expect(_product(te: '').displayName(true), 'Tomato');
      expect(_product(en: '').displayName(false), 'టమాటా');
    });

    test('search matches English (any case) and Telugu names', () {
      expect(_product().matches('tom'), isTrue);
      expect(_product().matches('TOM'), isTrue);
      expect(_product().matches('టమా'), isTrue);
      expect(_product().matches('onion'), isFalse);
      expect(_product().matches(''), isTrue);
    });

    test('round-trips through a Firestore map', () {
      final p = Product.fromMap('id1', _product().toMap());
      expect(p.id, 'id1');
      expect(p.price, 45);
      expect(p.quantity, 2.5);
      expect(p.cropKey, 'tomato');
    });

    test('formats numbers without needless decimals', () {
      expect(formatNumber(25), '25');
      expect(formatNumber(2.5), '2.5');
    });
  });

  group('Strings', () {
    test('Telugu and English differ', () {
      const te = S(true);
      const en = S(false);
      expect(te.login, isNot(en.login));
      expect(te.unitName('kg'), 'కిలో');
      expect(en.unitName('kg'), 'kg');
    });
  });

  test('theme text styles keep a dark colour (typed text must be visible)', () {
    for (final telugu in [true, false]) {
      final tt = buildTheme(telugu: telugu).textTheme;
      for (final style in [tt.bodyLarge, tt.bodyMedium, tt.titleLarge, tt.titleMedium]) {
        expect(style?.color, AppColors.text);
      }
    }
  });

  testWidgets('crop tiles and wizard buttons do not overflow with big fonts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340); // typical phone
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    final crops = Catalog.cropsIn('vegetables');
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(telugu: false),
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(AppMaterial.maxTextScale)),
        child: Scaffold(
          body: Column(children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
                children: [
                  for (final c in crops) PictureTile(emoji: c.emoji, label: c.en, onTap: () {}),
                  PictureTile(emoji: '🌿', label: 'కాలీఫ్లవర్ పచ్చిమిర్చి', onTap: () {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Expanded(child: BigButton(icon: Icons.arrow_back, label: 'వెనక్కి', outlined: true, onPressed: () {})),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: BigButton(icon: Icons.check_circle, label: 'పంట సేవ్ చేయండి', onPressed: () {})),
              ]),
            ),
          ]),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('first screen lets the user pick Telugu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lang = LanguageController();
    await lang.load();
    expect(lang.hasChosen, isFalse);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: lang,
      child: const MaterialApp(home: LanguageScreen()),
    ));
    expect(find.text('తెలుగు'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('తెలుగు'));
    await tester.pump();
    expect(lang.hasChosen, isTrue);
    expect(lang.isTelugu, isTrue);
  });
}
