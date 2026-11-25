import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../state/language_controller.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../buyer/my_enquiries_screen.dart';
import 'edit_profile_screen.dart';

/// Profile, language, helpline and logout — shared by buyers and sellers.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final session = context.watch<SessionController>();
    final lang = context.watch<LanguageController>();
    final user = session.user;
    if (user == null) return const LoadingView();

    Widget tile(IconData icon, String label, VoidCallback onTap, {Color? color}) => Card(
          elevation: 0,
          color: AppColors.greyCard,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(icon, color: color ?? AppColors.green, size: 32),
            title: Text(label, style: TextStyle(fontSize: 20, color: color)),
            trailing: Icon(Icons.chevron_right, size: 30, color: color ?? AppColors.green),
            onTap: onTap,
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(s.account)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.greenLight,
              child: Text(user.isSeller ? '👨‍🌾' : '🛒', style: const TextStyle(fontSize: 54)),
            ),
          ),
          const SizedBox(height: 10),
          Text(user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          Text(user.isSeller ? s.seller : s.buyer,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: AppColors.green)),
          const SizedBox(height: 12),
          InfoRow(icon: Icons.phone_android, text: '+91 ${user.phone}'),
          if (user.pincode.isNotEmpty)
            InfoRow(
              icon: Icons.location_on,
              text: [user.placeLine, user.state, user.pincode].where((e) => e.isNotEmpty).join(', '),
            ),
          const SizedBox(height: 12),
          tile(Icons.edit, s.editProfile, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),
          if (!user.isSeller)
            tile(Icons.list_alt, s.myEnquiries, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEnquiriesScreen()));
            }),
          tile(Icons.translate, '${s.language}: ${lang.isTelugu ? 'తెలుగు' : 'English'}',
              () => lang.setLanguage(lang.isTelugu ? 'en' : 'te')),
          tile(Icons.support_agent, s.helpline, () => callNumber(AppConfig.helplineNumber)),
          tile(Icons.logout, s.logout, () async {
            if (await confirm(context, s.logoutConfirm)) await session.logout();
          }, color: AppColors.danger),
        ],
      ),
    );
  }
}
