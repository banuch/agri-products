import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/app_user.dart';
import '../../widgets/common.dart';
import 'login_screen.dart';

/// "Who are you?" — two large picture cards for Seller (farmer) and Buyer.
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    void go(UserRole role) => Navigator.push(
        context, MaterialPageRoute(builder: (_) => LoginScreen(role: role)));

    return Scaffold(
      appBar: AppBar(actions: const [LanguageSwitch()]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(s.whoAreYou,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
            const SizedBox(height: 28),
            _RoleCard(
              emoji: '👨‍🌾',
              title: s.seller,
              hint: s.sellerHint,
              onTap: () => go(UserRole.seller),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              emoji: '🛒',
              title: s.buyer,
              hint: s.buyerHint,
              onTap: () => go(UserRole.buyer),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.emoji, required this.title, required this.hint, required this.onTap});

  final String emoji;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
