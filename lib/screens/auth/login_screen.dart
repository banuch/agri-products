import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import 'register_screen.dart';

String authErrorText(S s, AuthError e) {
  switch (e) {
    case AuthError.wrongLogin:
      return s.wrongLogin;
    case AuthError.mobileAlreadyUsed:
      return s.mobileAlreadyUsed;
    case AuthError.noInternet:
      return s.noInternet;
    case AuthError.unknown:
      return s.somethingWrong;
  }
}

/// Mobile number field with +91 prefix and a number keypad.
class MobileField extends StatelessWidget {
  const MobileField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
      style: const TextStyle(fontSize: 22, letterSpacing: 2),
      decoration: InputDecoration(
        labelText: s.mobileNumber,
        prefixIcon: const Icon(Icons.phone_android, color: AppColors.green, size: 28),
        prefixText: '+91 ',
      ),
      validator: (v) => AuthService.isValidMobile(v ?? '') ? null : s.invalidMobile,
    );
  }
}

/// 6-digit PIN field (numbers only, hidden).
class PinField extends StatefulWidget {
  const PinField({super.key, required this.controller, required this.label, this.validator});

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      obscureText: _hidden,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
      style: const TextStyle(fontSize: 22, letterSpacing: 6),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock, color: AppColors.green, size: 28),
        suffixIcon: IconButton(
          iconSize: 28,
          icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
      validator: widget.validator ??
          (v) => AuthService.isValidPin(v ?? '') ? null : s.invalidPin,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _mobile = TextEditingController();
  final _pin = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _mobile.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final s = S.read(context);
    setState(() => _busy = true);
    try {
      await context.read<AuthService>().login(_mobile.text, _pin.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on AuthException catch (e) {
      if (mounted) showMessage(context, authErrorText(s, e.error), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _forgotPin() {
    final s = S.read(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.forgotPin),
        content: Text(s.forgotPinHelp, style: const TextStyle(fontSize: 19)),
        actions: [
          BigButton(
            icon: Icons.call,
            label: s.callHelpline,
            onPressed: () {
              Navigator.pop(ctx);
              callNumber(AppConfig.helplineNumber);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isSeller = widget.role == UserRole.seller;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageSwitch()]),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.greenLight,
                  child: Text(isSeller ? '👨‍🌾' : '🛒', style: const TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 16),
              Text(s.welcomeBack,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
              Text('${s.signInToContinue} (${isSeller ? s.seller : s.buyer})',
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
              MobileField(controller: _mobile),
              const SizedBox(height: 16),
              PinField(controller: _pin, label: s.pin),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPin,
                  child: Text(s.forgotPin, style: const TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(height: 8),
              BigButton(icon: Icons.login, label: s.login, busy: _busy, onPressed: _login),
              const SizedBox(height: 32),
              Text(s.noAccount, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              BigButton(
                icon: Icons.person_add,
                label: s.createAccount,
                outlined: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen(role: widget.role)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
