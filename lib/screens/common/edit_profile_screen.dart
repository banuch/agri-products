import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/app_user.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/location_picker.dart';

/// Change name, pincode/village and address. A seller's crops are moved to
/// the new location automatically.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final AppUser _user;
  late final TextEditingController _name;
  late final TextEditingController _address;
  late LocationValue _location;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _user = context.read<SessionController>().user!;
    _name = TextEditingController(text: _user.name);
    _address = TextEditingController(text: _user.address);
    _location = LocationValue(
      pincode: _user.pincode,
      village: _user.village,
      district: _user.district,
      state: _user.state,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.read(context);
    if (!_form.currentState!.validate()) return;
    if (_user.isSeller && !_location.isComplete) {
      showMessage(context, s.pincodeHelp, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<DataService>().updateUser(_user.copyWith(
            name: _name.text.trim(),
            pincode: _location.pincode,
            village: _location.village,
            district: _location.district,
            state: _location.state,
            address: _address.text.trim(),
          ));
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, s.saved);
    } catch (_) {
      if (mounted) showMessage(context, s.somethingWrong, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.editProfile)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: s.yourName,
                prefixIcon: const Icon(Icons.person, color: AppColors.green, size: 28),
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? s.required : null,
            ),
            const SizedBox(height: 20),
            LocationPicker(
              required: _user.isSeller,
              initial: _location,
              onChanged: (v) => _location = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              style: const TextStyle(fontSize: 19),
              decoration: InputDecoration(
                labelText: s.address,
                prefixIcon: const Icon(Icons.home, color: AppColors.green, size: 28),
              ),
            ),
            const SizedBox(height: 28),
            BigButton(icon: Icons.save, label: s.save, busy: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
