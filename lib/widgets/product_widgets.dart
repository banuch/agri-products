import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../l10n/strings.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/data_service.dart';
import '../services/pincode_service.dart';

String priceText(S s, Product p) => '₹${formatNumber(p.price)} / ${s.unitName(p.unit)}';

String quantityText(S s, double qty, String unit) => '${formatNumber(qty)} ${s.unitName(unit)}';

/// Product row like the mockup: photo, name, price, place.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap, this.extraLine});

  final Product product;
  final VoidCallback onTap;

  /// Optional extra text under the price (e.g. quantity on "My Crops").
  final String? extraLine;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Card(
      color: AppColors.greyCard,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumb(product: product),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.displayName(s.isTelugu),
                        style: const TextStyle(
                            fontSize: 22, color: AppColors.green, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(priceText(s, product),
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                    if (extraLine != null)
                      Text(extraLine!, style: const TextStyle(fontSize: 17)),
                    if (product.placeLine.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.black54),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(product.placeLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, color: Colors.black54)),
                        ),
                      ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 32, color: AppColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    // Imported lazily to keep this file free of network image code paths.
    return SizedBox(
      width: 76,
      height: 76,
      child: product.imageUrls.isEmpty
          ? Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(product.emoji, style: const TextStyle(fontSize: 42)),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Center(child: Text(product.emoji, style: const TextStyle(fontSize: 42))),
              ),
            ),
    );
  }
}

/// Chips to filter by "All places", "My district", or a typed pincode.
class PlaceFilterBar extends StatelessWidget {
  const PlaceFilterBar({super.key, required this.user, required this.value, required this.onChanged});

  final AppUser? user;
  final PlaceFilter value;
  final ValueChanged<PlaceFilter> onChanged;

  Future<void> _askPincode(BuildContext context) async {
    final s = S.read(context);
    final ctrl = TextEditingController(text: value.field == 'pincode' ? value.value : user?.pincode);
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.enterPincode),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, letterSpacing: 4),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 52)),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(s.search),
          ),
        ],
      ),
    );
    if (pin == null) return;
    if (!PincodeService.isValid(pin)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.invalidPincode)));
      }
      return;
    }
    onChanged(PlaceFilter.pincode(pin));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final district = user?.district ?? '';
    Widget chip(String label, IconData icon, bool selected, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            avatar: Icon(icon, size: 20, color: selected ? Colors.white : AppColors.green),
            label: Text(label, style: TextStyle(fontSize: 16, color: selected ? Colors.white : AppColors.text)),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.green,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            onSelected: (_) => onTap(),
          ),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          chip(s.filterAll, Icons.public, value.isAll, () => onChanged(const PlaceFilter.all())),
          if (district.isNotEmpty)
            chip(s.filterMyDistrict(district), Icons.map, value.field == 'district',
                () => onChanged(PlaceFilter.district(district))),
          chip(
            value.field == 'pincode' ? s.filterPincodeValue(value.value!) : s.filterPincode,
            Icons.pin_drop,
            value.field == 'pincode',
            () => _askPincode(context),
          ),
        ],
      ),
    );
  }
}
