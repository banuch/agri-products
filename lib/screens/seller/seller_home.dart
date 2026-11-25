import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../models/enquiry.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../common/account_screen.dart';
import 'my_products_screen.dart';
import 'seller_enquiries_screen.dart';

/// Seller home: My Crops · Enquiries (with count of new ones) · Account.
class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  int _index = 0;
  late final Stream<List<Enquiry>> _enquiries;

  @override
  void initState() {
    super.initState();
    final uid = context.read<SessionController>().user!.uid;
    _enquiries = context.read<DataService>().watchSellerEnquiries(uid).asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const MyProductsScreen(),
          SellerEnquiriesScreen(stream: _enquiries),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<List<Enquiry>>(
        stream: _enquiries,
        builder: (context, snap) {
          final newCount = snap.data?.where((e) => e.isNew).length ?? 0;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.agriculture), label: s.myProducts),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: newCount > 0,
                  label: Text('$newCount'),
                  child: const Icon(Icons.notifications),
                ),
                label: s.enquiries,
              ),
              NavigationDestination(icon: const Icon(Icons.person), label: s.account),
            ],
          );
        },
      ),
    );
  }
}
