import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/catalog.dart';
import '../../l10n/strings.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_widgets.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key, required this.category});

  final CropCategory category;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  PlaceFilter _filter = const PlaceFilter.all();
  late Stream<List<Product>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _load();
  }

  Stream<List<Product>> _load() => context
      .read<DataService>()
      .watchProducts(category: widget.category.key, filter: _filter);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = context.watch<SessionController>().user;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category.emoji} ${widget.category.name(s.isTelugu)}')),
      body: Column(
        children: [
          PlaceFilterBar(
            user: user,
            value: _filter,
            onChanged: (f) => setState(() {
              _filter = f;
              _stream = _load();
            }),
          ),
          Expanded(child: ProductStreamList(stream: _stream)),
        ],
      ),
    );
  }
}

/// Shows a live product list with loading/empty/error states.
class ProductStreamList extends StatelessWidget {
  const ProductStreamList({super.key, required this.stream, this.where, this.header});

  final Stream<List<Product>> stream;
  final bool Function(Product)? where;

  /// Optional widget scrolled together with the list (above the items).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return StreamBuilder<List<Product>>(
      stream: stream,
      builder: (context, snap) {
        Widget? status;
        List<Product> items = const [];
        if (snap.hasError) {
          status = MessageView(emoji: '⚠️', message: s.somethingWrong);
        } else if (!snap.hasData) {
          status = const LoadingView();
        } else {
          items = where == null ? snap.data! : snap.data!.where(where!).toList();
          if (items.isEmpty) status = MessageView(emoji: '🧺', message: s.noProducts);
        }
        if (header == null && status != null) return status;
        final lead = [?header, ?status];
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: lead.length + items.length,
          itemBuilder: (context, index) {
            if (index < lead.length) return lead[index];
            final i = index - lead.length;
            return ProductTile(
              product: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: items[i].id)),
              ),
            );
          },
        );
      },
    );
  }
}
