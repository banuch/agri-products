import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/product_widgets.dart';
import 'product_list_screen.dart';

/// Search crops by name (English or Telugu), optionally by place.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  PlaceFilter _filter = const PlaceFilter.all();
  late Stream<List<Product>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _load();
  }

  Stream<List<Product>> _load() => context.read<DataService>().watchProducts(filter: _filter);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = context.watch<SessionController>().user;
    return Scaffold(
      appBar: AppBar(title: Text(s.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _query,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.green, size: 30),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_query.clear),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          PlaceFilterBar(
            user: user,
            value: _filter,
            onChanged: (f) => setState(() {
              _filter = f;
              _stream = _load();
            }),
          ),
          Expanded(
            child: ProductStreamList(
              stream: _stream,
              where: (p) => p.matches(_query.text),
            ),
          ),
        ],
      ),
    );
  }
}
