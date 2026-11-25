import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/enquiry.dart';
import '../../services/data_service.dart';
import '../../widgets/common.dart';
import '../../widgets/product_widgets.dart';
import '../buyer/my_enquiries_screen.dart' show StatusChip;

/// Enquiries buyers sent to this seller, with Call and "Mark as done".
class SellerEnquiriesScreen extends StatelessWidget {
  const SellerEnquiriesScreen({super.key, required this.stream});

  final Stream<List<Enquiry>> stream;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.enquiries)),
      body: StreamBuilder<List<Enquiry>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) return MessageView(emoji: '⚠️', message: s.somethingWrong);
          if (!snap.hasData) return const LoadingView();
          final list = snap.data!;
          if (list.isEmpty) return MessageView(emoji: '📭', message: s.noEnquiries);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _EnquiryCard(enquiry: list[i]),
          );
        },
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({required this.enquiry});

  final Enquiry enquiry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final e = enquiry;
    return Card(
      elevation: 0,
      color: e.isNew ? AppColors.greenLight : AppColors.greyCard,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: e.isNew ? const BorderSide(color: AppColors.green, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.productName(s.isTelugu),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.green)),
            const SizedBox(height: 4),
            InfoRow(icon: Icons.person, text: '${s.enquiryFrom}: ${e.buyerName}'),
            InfoRow(icon: Icons.shopping_basket, text: '${s.wants}: ${quantityText(s, e.quantity, e.unit)}'),
            if (e.message.isNotEmpty) InfoRow(icon: Icons.chat, text: e.message),
            StatusChip(isNew: e.isNew),
            const SizedBox(height: 12),
            BigButton(icon: Icons.call, label: s.callBuyer, onPressed: () => callNumber(e.buyerPhone)),
            if (e.isNew) ...[
              const SizedBox(height: 10),
              BigButton(
                icon: Icons.done_all,
                label: s.markResponded,
                outlined: true,
                onPressed: () async {
                  try {
                    await context.read<DataService>().markResponded(e.id);
                  } catch (_) {
                    if (context.mounted) showMessage(context, s.somethingWrong, error: true);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
