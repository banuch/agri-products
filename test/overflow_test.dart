// Draws every screen (and its dialogs / wizard steps) in Telugu and English,
// on a small and a large phone, with the phone font size turned up to the
// maximum, and fails on any layout overflow.

import 'package:agri_society/app.dart';
import 'package:agri_society/l10n/strings.dart';
import 'package:agri_society/models/app_user.dart';
import 'package:agri_society/models/enquiry.dart';
import 'package:agri_society/models/product.dart';
import 'package:agri_society/screens/auth/language_screen.dart';
import 'package:agri_society/screens/auth/login_screen.dart';
import 'package:agri_society/screens/auth/register_screen.dart';
import 'package:agri_society/screens/auth/role_screen.dart';
import 'package:agri_society/screens/auth/welcome_screen.dart';
import 'package:agri_society/screens/buyer/buyer_home.dart';
import 'package:agri_society/screens/buyer/my_enquiries_screen.dart';
import 'package:agri_society/screens/buyer/product_detail_screen.dart';
import 'package:agri_society/screens/buyer/product_list_screen.dart';
import 'package:agri_society/screens/buyer/seller_profile_screen.dart';
import 'package:agri_society/screens/common/account_screen.dart';
import 'package:agri_society/screens/common/edit_profile_screen.dart';
import 'package:agri_society/screens/seller/product_wizard.dart';
import 'package:agri_society/screens/seller/seller_home.dart';
import 'package:agri_society/core/catalog.dart';
import 'package:agri_society/services/auth_service.dart';
import 'package:agri_society/services/data_service.dart';
import 'package:agri_society/services/pincode_service.dart';
import 'package:agri_society/state/language_controller.dart';
import 'package:agri_society/state/session_controller.dart';
import 'package:agri_society/widgets/common.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- Sample data: deliberately long names and big numbers ----
const _longPlace = 'Sri Potti Sriramulu Nellore';

const seller = AppUser(
  uid: 'seller1',
  role: UserRole.seller,
  name: 'Venkata Subrahmanyam Chowdary Kotamreddy',
  phone: '9876543210',
  pincode: '524121',
  village: 'Dos Colony Kavali Rural',
  district: _longPlace,
  state: 'Andhra Pradesh',
  address: 'C3-437, Main Road',
);

const buyer = AppUser(
  uid: 'buyer1',
  role: UserRole.buyer,
  name: 'Lakshmi Narasimha Prasad Reddy Gari',
  phone: '9123456780',
  pincode: '522001',
  village: 'Guntur Bazar',
  district: 'Guntur',
  state: 'Andhra Pradesh',
);

final products = <Product>[
  Product(
    id: 'p1',
    sellerId: seller.uid,
    sellerName: seller.name,
    sellerPhone: seller.phone,
    category: 'vegetables',
    cropKey: 'cauliflower',
    nameEn: 'Cauliflower',
    nameTe: 'కాలీఫ్లవర్',
    unit: 'quintal',
    price: 123456.5,
    quantity: 99999,
    description: 'Fresh organic cauliflower, harvested this morning. ' * 4,
    pincode: seller.pincode,
    village: seller.village,
    district: seller.district,
    state: seller.state,
    createdAt: DateTime(2026, 11, 1),
  ),
  Product(
    id: 'p2',
    sellerId: seller.uid,
    sellerName: seller.name,
    sellerPhone: seller.phone,
    category: 'vegetables',
    cropKey: 'other',
    nameEn: 'Very long local variety name of country brinjal',
    nameTe: 'చాలా పొడవైన స్థానిక నాటు వంకాయ రకం పేరు',
    unit: 'dozen',
    price: 25,
    quantity: 2.5,
    pincode: seller.pincode,
    village: seller.village,
    district: seller.district,
    state: seller.state,
    createdAt: DateTime(2026, 11, 2),
  ),
];

final enquiries = <Enquiry>[
  Enquiry(
    id: 'e1',
    productId: 'p1',
    productNameEn: 'Cauliflower',
    productNameTe: 'కాలీఫ్లవర్',
    unit: 'quintal',
    sellerId: seller.uid,
    sellerName: seller.name,
    sellerPhone: seller.phone,
    buyerId: buyer.uid,
    buyerName: buyer.name,
    buyerPhone: buyer.phone,
    quantity: 12345.5,
    message: 'Please deliver to Guntur market yard before Sunday morning. ' * 2,
  ),
  Enquiry(
    id: 'e2',
    productId: 'p2',
    productNameEn: products[1].nameEn,
    productNameTe: products[1].nameTe,
    unit: 'dozen',
    sellerId: seller.uid,
    sellerName: seller.name,
    sellerPhone: seller.phone,
    buyerId: buyer.uid,
    buyerName: buyer.name,
    buyerPhone: buyer.phone,
    quantity: 3,
    status: 'responded',
  ),
];

// ---------------- Fakes (no Firebase) ----------------
class FakeAuth implements AuthService {
  @override
  Stream<User?> authChanges() => const Stream.empty();
  @override
  Future<void> login(String mobile, String pin) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register({required String mobile, required String pin, required AppUser profileWithoutUid}) async {}
}

class FakeData implements DataService {
  @override
  Stream<AppUser?> watchUser(String uid) => Stream.value(uid == seller.uid ? seller : buyer);
  @override
  Future<AppUser?> getUser(String uid) async => uid == seller.uid ? seller : buyer;
  @override
  Future<void> updateUser(AppUser user) async {}
  @override
  Stream<List<Product>> watchProducts({String? category, PlaceFilter filter = const PlaceFilter.all()}) =>
      Stream.value(products);
  @override
  Stream<List<Product>> watchSellerProducts(String sellerId) => Stream.value(products);
  @override
  Stream<Product?> watchProduct(String id) => Stream.value(products.firstWhere((p) => p.id == id));
  @override
  Future<void> saveProduct(Product product, {newImages = const [], removedUrls = const []}) async {}
  @override
  Future<void> deleteProduct(Product product) async {}
  @override
  Future<void> sendEnquiry(Enquiry e) async {}
  @override
  Stream<List<Enquiry>> watchSellerEnquiries(String sellerId) => Stream.value(enquiries);
  @override
  Stream<List<Enquiry>> watchBuyerEnquiries(String buyerId) => Stream.value(enquiries);
  @override
  Future<void> markResponded(String enquiryId) async {}
}

const _pincodeBody = '[{"Message":"Number of pincode(s) found:3","Status":"Success","PostOffice":['
    '{"Name":"Dos Colony","District":"Nellore","State":"Andhra Pradesh"},'
    '{"Name":"Kavali Rural Agraharam Extension Post Office","District":"$_longPlace","State":"Andhra Pradesh"},'
    '{"Name":"Musunuru","District":"Nellore","State":"Andhra Pradesh"}]}]';

PincodeService pincodeService({bool online = true}) => PincodeService(
      client: MockClient((_) async =>
          online ? http.Response(_pincodeBody, 200) : throw http.ClientException('offline')),
    );

// ---------------- Harness ----------------
const sizes = {'small 320x600': Size(320, 600), 'large 412x915': Size(412, 915)};

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required bool telugu,
  required Size size,
  AppUser user = buyer,
  bool pincodeOnline = true,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  // "Huge font" phone; the app caps this at AppMaterial.maxTextScale.
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferences.setMockInitialValues({'app_language': telugu ? 'te' : 'en'});
  final lang = LanguageController();
  await lang.load();
  final auth = FakeAuth();
  final data = FakeData();

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: lang),
      Provider<AuthService>.value(value: auth),
      Provider<DataService>.value(value: data),
      Provider<PincodeService>.value(value: pincodeService(online: pincodeOnline)),
      ChangeNotifierProvider(create: (_) => SessionController.fixed(auth, data, user)),
    ],
    child: AppMaterial(home: screen),
  ));
  await settle(tester);
}

/// Let streams/futures deliver without waiting for endless spinners.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void expectNoOverflow(WidgetTester tester, String where) {
  final e = tester.takeException();
  var detail = '$e';
  if (e is FlutterError) {
    // Include the "relevant error-causing widget ... file:line" part.
    detail = e.diagnostics
        .map((d) => d.toString())
        .where((l) => l.contains('overflowed') || l.contains('lib/') || l.contains('error-causing'))
        .join(' | ');
  }
  expect(e, isNull, reason: '$where: $detail');
}

final _vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

/// Scrolls the page until [finder] exists, if it is not built yet.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _vertical.first);
  }
  await tester.ensureVisible(finder.first);
  await settle(tester);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text);
  await reveal(tester, f);
  await tester.tap(f.first);
  await settle(tester);
}

void main() {
  for (final telugu in [true, false]) {
    final s = S(telugu);
    final lang = telugu ? 'TE' : 'EN';
    for (final entry in sizes.entries) {
      final size = entry.value;
      final tag = '[$lang ${entry.key}]';

      Future<void> check(WidgetTester t, Widget screen, {AppUser user = buyer, bool pincodeOnline = true}) async {
        await pumpScreen(t, screen, telugu: telugu, size: size, user: user, pincodeOnline: pincodeOnline);
        expectNoOverflow(t, '${screen.runtimeType} $tag');
      }

      group(tag, () {
        testWidgets('language screen', (t) => check(t, const LanguageScreen()));
        testWidgets('welcome screen', (t) => check(t, const WelcomeScreen()));
        testWidgets('role screen', (t) => check(t, const RoleScreen()));

        testWidgets('login + forgot PIN dialog', (t) async {
          await check(t, const LoginScreen(role: UserRole.seller));
          await tapText(t, s.forgotPin);
          expectNoOverflow(t, 'forgot PIN dialog $tag');
        });

        testWidgets('register seller: pincode found, village list', (t) async {
          await check(t, const RegisterScreen(role: UserRole.seller));
          final pin = find.widgetWithText(TextFormField, s.pincode);
          await reveal(t, pin);
          await t.enterText(pin, '524121');
          await settle(t);
          expectNoOverflow(t, 'register (pincode found) $tag');
          // Pick the longest village name.
          await t.ensureVisible(find.text('Dos Colony'));
          await t.tap(find.text('Dos Colony'));
          await settle(t);
          await t.tap(find.text('Kavali Rural Agraharam Extension Post Office').last);
          await settle(t);
          expectNoOverflow(t, 'register (long village picked) $tag');
          // Submit empty form to show all validation errors.
          await tapText(t, s.createAccount);
          expectNoOverflow(t, 'register (validation errors) $tag');
        });

        testWidgets('register buyer: pincode lookup offline (manual)', (t) async {
          await check(t, const RegisterScreen(role: UserRole.buyer), pincodeOnline: false);
          final pin = find.widgetWithText(TextFormField, s.pincodeOptional);
          await reveal(t, pin);
          await t.enterText(pin, '524121');
          await settle(t);
          expectNoOverflow(t, 'register (manual district) $tag');
        });

        testWidgets('buyer home (account, categories, search tabs)', (t) async {
          await check(t, const BuyerHome());
          for (final label in [s.search, s.account]) {
            await t.tap(find.text(label).last);
            await settle(t);
            expectNoOverflow(t, 'buyer tab $label $tag');
          }
        });

        testWidgets('product list + pincode filter dialog', (t) async {
          await check(t, ProductListScreen(category: Catalog.categories.first));
          await tapText(t, s.filterPincode);
          expectNoOverflow(t, 'pincode filter dialog $tag');
        });

        testWidgets('product detail + enquiry sheet', (t) async {
          await check(t, const ProductDetailScreen(productId: 'p1'));
          await tapText(t, s.sendEnquiry);
          expectNoOverflow(t, 'enquiry sheet $tag');
        });

        testWidgets('product detail (long name, no photo)', (t) => check(t, const ProductDetailScreen(productId: 'p2')));
        testWidgets('seller profile', (t) => check(t, const SellerProfileScreen(sellerId: 'seller1')));
        testWidgets('my enquiries (buyer)', (t) => check(t, const MyEnquiriesScreen()));
        testWidgets('account (seller)', (t) => check(t, const AccountScreen(), user: seller));
        testWidgets('edit profile (seller)', (t) => check(t, const EditProfileScreen(), user: seller));

        testWidgets('seller home (crops, enquiries, account) + delete dialog', (t) async {
          await check(t, const SellerHome(), user: seller);
          await tapText(t, s.delete);
          expectNoOverflow(t, 'delete confirm dialog $tag');
          await t.tap(find.text(s.no).last);
          await settle(t);
          for (final label in [s.enquiries, s.account]) {
            await t.tap(find.text(label).last);
            await settle(t);
            expectNoOverflow(t, 'seller tab $label $tag');
          }
          await tapText(t, s.logout);
          expectNoOverflow(t, 'logout confirm dialog $tag');
        });

        testWidgets('add crop wizard, all 5 steps', (t) async {
          await check(t, const ProductWizard(), user: seller);
          // Step 1 -> pick the first category (moves to step 2).
          await t.tap(find.byType(PictureTile).first);
          await settle(t);
          expectNoOverflow(t, 'wizard step 2 $tag');
          // "Other" crop with typed name.
          final other = find.text(s.otherCrop);
          await t.dragUntilVisible(other, find.byType(GridView), const Offset(0, -300));
          await t.ensureVisible(other);
          await settle(t);
          await t.tap(other);
          await settle(t);
          expectNoOverflow(t, 'wizard step 2 (other) $tag');
          await t.enterText(find.byType(TextField).last, 'Very long local variety name of country brinjal');
          await settle(t);
          await tapText(t, s.next); // step 3 photos
          expectNoOverflow(t, 'wizard step 3 $tag');
          await tapText(t, s.next); // step 4 price & quantity
          expectNoOverflow(t, 'wizard step 4 $tag');
          for (var i = 0; i < 2; i++) {
            await reveal(t, find.byIcon(Icons.add));
            final plus = find.byIcon(Icons.add).at(find.byIcon(Icons.add).evaluate().length > 1 ? i : 0);
            await t.ensureVisible(plus);
            await t.tap(plus);
            await settle(t);
          }
          await tapText(t, s.next); // step 5 review
          expectNoOverflow(t, 'wizard step 5 $tag');
        });

        testWidgets('edit crop wizard (big numbers)', (t) async {
          await check(t, ProductWizard(existing: products.first), user: seller);
          await tapText(t, s.next);
          expectNoOverflow(t, 'edit wizard review $tag');
        });

        testWidgets('snackbar message', (t) async {
          await check(t, Builder(
            builder: (c) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showMessage(c, s.mobileAlreadyUsed, error: true),
                  child: const Text('go'),
                ),
              ),
            ),
          ));
          await t.tap(find.text('go'));
          await settle(t);
          expectNoOverflow(t, 'snackbar $tag');
        });
      });
    }
  }

}
