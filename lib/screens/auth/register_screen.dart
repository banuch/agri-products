import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/common.dart';
import '../../widgets/location_picker.dart';
import 'login_screen.dart';

/// Sign-up. Sellers must give their pincode (village/district/state are
/// filled automatically); for buyers the pincode is optional.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  final _address = TextEditingController();
  LocationValue _location = const LocationValue();
  bool _busy = false;

  bool get _isSeller => widget.role == UserRole.seller;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _pin, _pin2, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final s = S.read(context);
    if (!_form.currentState!.validate()) return;
    if (_isSeller && !_location.isComplete) {
      showMessage(context, s.pincodeHelp, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthService>().register(
            mobile: _mobile.text,
            pin: _pin.text,
            profileWithoutUid: AppUser(
              uid: '',
              role: widget.role,
              name: _name.text.trim(),
              phone: _mobile.text,
              pincode: _location.pincode,
              village: _location.village,
              district: _location.district,
              state: _location.state,
              address: _address.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on AuthException catch (e) {
      if (mounted) showMessage(context, authErrorText(s, e.error), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSeller ? s.registerAsSeller : s.registerAsBuyer),
        actions: const [LanguageSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Text(_isSeller ? '👨‍🌾' : '🛒', style: const TextStyle(fontSize: 64))),
              gap,
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: s.yourName,
                  prefixIcon: const Icon(Icons.person, color: AppColors.green, size: 28),
                ),
                validator: (v) => (v ?? '').trim().isEmpty ? s.required : null,
              ),
              gap,
              MobileField(controller: _mobile),
              gap,
              PinField(controller: _pin, label: s.pin),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Text(s.pinHelp, style: const TextStyle(fontSize: 15, color: Colors.black54)),
              ),
              gap,
              PinField(
                controller: _pin2,
                label: s.confirmPin,
                validator: (v) => v == _pin.text ? null : s.pinMismatch,
              ),
              const SizedBox(height: 28),
              Row(children: [
                const Icon(Icons.place, color: AppColors.green, size: 30),
                const SizedBox(width: 8),
                Text(s.location, style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 12),
              LocationPicker(required: _isSeller, onChanged: (v) => _location = v),
              gap,
              TextFormField(
                controller: _address,
                style: const TextStyle(fontSize: 19),
                decoration: InputDecoration(
                  labelText: s.address,
                  prefixIcon: const Icon(Icons.home, color: AppColors.green, size: 28),
                ),
              ),
              const SizedBox(height: 28),
              BigButton(
                icon: Icons.check_circle,
                label: s.createAccount,
                busy: _busy,
                onPressed: _register,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(s.haveAccount, style: const TextStyle(fontSize: 17)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(s.login, style: const TextStyle(fontSize: 17)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
