import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/logo.dart';
import 'role_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [LanguageSwitch()]),
      body: SafeArea(
        child: FillScroll(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.welcomeTo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, color: AppColors.green)),
              const Spacer(),
              const Center(child: AppLogo(size: 170)),
              const SizedBox(height: 20),
              Text(s.appName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 28, color: AppColors.green, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(s.tagline, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19)),
              const SizedBox(height: 20),
              BigButton(
                icon: Icons.arrow_forward,
                label: s.getStarted,
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const RoleScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
