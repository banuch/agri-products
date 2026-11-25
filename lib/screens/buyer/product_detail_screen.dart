import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/enquiry.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_widgets.dart';
import 'seller_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final Stream<Product?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<DataService>().watchProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return StreamBuilder<Product?>(
      stream: _stream,
      builder: (context, snap) {
        final p = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(p?.displayName(s.isTelugu) ?? '')),
          body: snap.hasError
              ? MessageView(emoji: '⚠️', message: s.somethingWrong)
              : snap.connectionState == ConnectionState.waiting
                  ? const LoadingView()
                  : p == null
                      ? MessageView(emoji: '🧺', message: s.noProducts)
                      : _Body(product: p),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = product;
    final me = context.watch<SessionController>().user;
    final isOwn = me?.uid == p.sellerId;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        _Photos(product: p),
        const SizedBox(height: 12),
        Text(p.displayName(s.isTelugu),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            InfoRow(icon: Icons.currency_rupee, text: '${s.price}: ${priceText(s, p)}'),
            InfoRow(icon: Icons.inventory_2, text: '${s.available}: ${quantityText(s, p.quantity, p.unit)}'),
            if (p.placeLine.isNotEmpty)
              InfoRow(icon: Icons.location_on, text: '${p.placeLine} - ${p.pincode}'),
          ]),
        ),
        if (p.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(p.description, style: const TextStyle(fontSize: 18)),
        ],
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: AppColors.greyCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const CircleAvatar(
                radius: 26, backgroundColor: Colors.white, child: Text('👨‍🌾', style: TextStyle(fontSize: 28))),
            title: Text(s.soldBy, style: const TextStyle(fontSize: 15)),
            subtitle: Text(p.sellerName,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.text)),
            trailing: const Icon(Icons.chevron_right, size: 32, color: AppColors.green),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SellerProfileScreen(sellerId: p.sellerId)),
            ),
          ),
        ),
        if (!isOwn) ...[
          const SizedBox(height: 20),
          Text(s.contactOwner,
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          BigButton(icon: Icons.call, label: s.callOwner, onPressed: () => callNumber(p.sellerPhone)),
          const SizedBox(height: 12),
          BigButton(
            icon: Icons.send,
            label: s.sendEnquiry,
            outlined: true,
            onPressed: me == null ? null : () => _openEnquiry(context, p),
          ),
        ],
      ],
    );
  }

  void _openEnquiry(BuildContext context, Product p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EnquirySheet(product: p),
    );
  }
}

class _Photos extends StatefulWidget {
  const _Photos({required this.product});

  final Product product;

  @override
  State<_Photos> createState() => _PhotosState();
}

class _PhotosState extends State<_Photos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.product.imageUrls;
    final width = MediaQuery.sizeOf(context).width - 40;
    if (urls.isEmpty) {
      return Center(child: ProductImage(emoji: widget.product.emoji, size: 200));
    }
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => ProductImage(
                url: urls[i], emoji: widget.product.emoji, size: width, fit: BoxFit.cover),
          ),
        ),
        if (urls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? AppColors.green : AppColors.green.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom sheet where a buyer says how much they need and sends an enquiry.
class EnquirySheet extends StatefulWidget {
  const EnquirySheet({super.key, required this.product});

  final Product product;

  @override
  State<EnquirySheet> createState() => _EnquirySheetState();
}

class _EnquirySheetState extends State<EnquirySheet> {
  final _qty = TextEditingController(text: '1');
  final _msg = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _qty.dispose();
    _msg.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final v = (double.tryParse(_qty.text) ?? 0) + delta;
    setState(() => _qty.text = formatNumber(v < 1 ? 1 : v));
  }

  Future<void> _send() async {
    final s = S.read(context);
    final qty = double.tryParse(_qty.text) ?? 0;
    if (qty <= 0) {
      showMessage(context, s.invalidNumber, error: true);
      return;
    }
    final me = context.read<SessionController>().user!;
    final p = widget.product;
    setState(() => _busy = true);
    try {
      await context.read<DataService>().sendEnquiry(Enquiry(
            productId: p.id,
            productNameEn: p.nameEn,
            productNameTe: p.nameTe,
            unit: p.unit,
            sellerId: p.sellerId,
            sellerName: p.sellerName,
            sellerPhone: p.sellerPhone,
            buyerId: me.uid,
            buyerName: me.name,
            buyerPhone: me.phone,
            quantity: qty,
            message: _msg.text.trim(),
          ));
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, s.enquirySent);
    } catch (_) {
      if (mounted) showMessage(context, s.somethingWrong, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(s.howMuchYouNeed, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          NumberStepper(
            controller: _qty,
            suffix: s.unitName(widget.product.unit),
            onMinus: () => _step(-1),
            onPlus: () => _step(1),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msg,
            maxLines: 2,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: s.messageOptional,
              prefixIcon: const Icon(Icons.chat, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 20),
          BigButton(icon: Icons.send, label: s.sendEnquiry, busy: _busy, onPressed: _send),
        ],
      ),
    );
  }
}

/// [ − ]  number  [ + ]  — easy quantity/price entry without much typing.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.controller,
    required this.onMinus,
    required this.onPlus,
    this.suffix,
    this.prefix,
    this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String? suffix;
  final String? prefix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    Widget roundBtn(IconData icon, VoidCallback onTap) => Material(
          color: AppColors.green,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        );
    return Row(
      children: [
        roundBtn(Icons.remove, onMinus),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: prefix,
              suffixText: suffix,
              suffixStyle: const TextStyle(fontSize: 18, color: AppColors.text),
              prefixStyle: const TextStyle(fontSize: 24, color: AppColors.text),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        roundBtn(Icons.add, onPlus),
      ],
    );
  }
}
