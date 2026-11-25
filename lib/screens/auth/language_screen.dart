import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../state/language_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/logo.dart';

/// Very first screen: pick Telugu or English. Both labels are shown in
/// both languages so anyone can choose.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageController>();
    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AppLogo()),
              const SizedBox(height: 32),
              const Text('మీ భాషను ఎంచుకోండి\nChoose your language',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              _LangCard(
                big: 'తెలుగు',
                small: 'Telugu',
                letter: 'అ',
                onTap: () => lang.setLanguage('te'),
              ),
              const SizedBox(height: 20),
              _LangCard(
                big: 'English',
                small: 'ఇంగ్లీష్',
                letter: 'A',
                onTap: () => lang.setLanguage('en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  const _LangCard({required this.big, required this.small, required this.letter, required this.onTap});

  final String big;
  final String small;
  final String letter;
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(letter,
                    style: const TextStyle(fontSize: 30, color: AppColors.green, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(big, style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(small, style: const TextStyle(fontSize: 17, color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
