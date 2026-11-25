import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_widgets.dart';
import 'product_wizard.dart';

/// The seller's own crops with big Edit / Delete buttons on each.
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late final Stream<List<Product>> _stream;

  @override
  void initState() {
    super.initState();
    final uid = context.read<SessionController>().user!.uid;
    _stream = context.read<DataService>().watchSellerProducts(uid);
  }

  void _openWizard([Product? existing]) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductWizard(existing: existing)),
      );

  Future<void> _delete(Product p) async {
    final s = S.read(context);
    final ok = await confirm(context, '${p.displayName(s.isTelugu)}\n\n${s.deleteCropConfirm}', danger: true);
    if (!ok || !mounted) return;
    try {
      await context.read<DataService>().deleteProduct(p);
    } catch (_) {
      if (mounted) showMessage(context, s.somethingWrong, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.myProducts), actions: const [LanguageSwitch()]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 64,
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          onPressed: _openWizard,
          icon: const Icon(Icons.add_circle, size: 34),
          label: Text(s.addCrop, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) return MessageView(emoji: '⚠️', message: s.somethingWrong);
          if (!snap.hasData) return const LoadingView();
          final list = snap.data!;
          if (list.isEmpty) return MessageView(emoji: '🌱', message: s.noCropsYet);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              return Column(
                children: [
                  ProductTile(
                    product: p,
                    onTap: () => _openWizard(p),
                    extraLine: '${s.available}: ${quantityText(s, p.quantity, p.unit)}',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BigButton(
                          icon: Icons.edit,
                          label: s.edit,
                          outlined: true,
                          onPressed: () => _openWizard(p),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BigButton(
                          icon: Icons.delete,
                          label: s.delete,
                          outlined: true,
                          color: AppColors.danger,
                          onPressed: () => _delete(p),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
