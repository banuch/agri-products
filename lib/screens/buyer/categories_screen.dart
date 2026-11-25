import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.allCategories), actions: const [LanguageSwitch()]),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.95,
        ),
        itemCount: Catalog.categories.length,
        itemBuilder: (context, i) {
          final c = Catalog.categories[i];
          return PictureTile(
            emoji: c.emoji,
            label: c.name(s.isTelugu),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductListScreen(category: c)),
            ),
          );
        },
      ),
    );
  }
}
