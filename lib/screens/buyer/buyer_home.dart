import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../common/account_screen.dart';
import 'categories_screen.dart';
import 'search_screen.dart';

/// Buyer home with bottom bar: Account · Category · Search (as in mockups).
class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [AccountScreen(), CategoriesScreen(), SearchScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: s.account),
          NavigationDestination(icon: const Icon(Icons.grid_view), label: s.category),
          NavigationDestination(icon: const Icon(Icons.search), label: s.search),
        ],
      ),
    );
  }
}
