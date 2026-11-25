import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/enquiry.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_widgets.dart';

/// Enquiries the buyer has sent, with status and a call button.
class MyEnquiriesScreen extends StatefulWidget {
  const MyEnquiriesScreen({super.key});

  @override
  State<MyEnquiriesScreen> createState() => _MyEnquiriesScreenState();
}

class _MyEnquiriesScreenState extends State<MyEnquiriesScreen> {
  late final Stream<List<Enquiry>> _stream;

  @override
  void initState() {
    super.initState();
    final me = context.read<SessionController>().user!;
    _stream = context.read<DataService>().watchBuyerEnquiries(me.uid);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.myEnquiries)),
      body: StreamBuilder<List<Enquiry>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) return MessageView(emoji: '⚠️', message: s.somethingWrong);
          if (!snap.hasData) return const LoadingView();
          final list = snap.data!;
          if (list.isEmpty) return MessageView(emoji: '📭', message: s.noEnquiries);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final e = list[i];
              return Card(
                elevation: 0,
                color: AppColors.greyCard,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.productName(s.isTelugu),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.green)),
                      InfoRow(icon: Icons.person, text: e.sellerName),
                      InfoRow(icon: Icons.shopping_basket, text: quantityText(s, e.quantity, e.unit)),
                      StatusChip(isNew: e.isNew),
                      const SizedBox(height: 12),
                      BigButton(icon: Icons.call, label: s.callOwner, onPressed: () => callNumber(e.sellerPhone)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.isNew});

  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Chip(
      avatar: Icon(isNew ? Icons.hourglass_top : Icons.check_circle,
          color: isNew ? Colors.orange.shade800 : AppColors.green),
      label: Text(isNew ? s.statusNew : s.statusResponded, style: const TextStyle(fontSize: 16)),
      backgroundColor: Colors.white,
    );
  }
}
