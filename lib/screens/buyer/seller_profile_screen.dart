import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../widgets/common.dart';
import 'product_list_screen.dart';

/// Public farmer profile: name, place, call button and their other crops.
class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  late final Future<AppUser?> _seller;
  late final Stream<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    final data = context.read<DataService>();
    _seller = data.getUser(widget.sellerId);
    _products = data.watchSellerProducts(widget.sellerId);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.sellerDetails)),
      body: FutureBuilder<AppUser?>(
        future: _seller,
        builder: (context, snap) {
          if (snap.hasError) {
            return MessageView(emoji: '⚠️', message: s.somethingWrong);
          }
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final seller = snap.data;
          if (seller == null) {
            return MessageView(emoji: '👤', message: s.somethingWrong);
          }
          // Header and crops scroll together, so it fits any screen height.
          return ProductStreamList(
            stream: _products,
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.greenLight,
                    child: Text('👨‍🌾', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    seller.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InfoRow(
                    icon: Icons.location_on,
                    text: [
                      seller.placeLine,
                      seller.state,
                      seller.pincode,
                    ].where((e) => e.isNotEmpty).join(', '),
                  ),
                  const SizedBox(height: 8),
                  BigButton(
                    icon: Icons.call,
                    label: s.call,
                    onPressed: () => callNumber(seller.phone),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      s.otherCrops,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
