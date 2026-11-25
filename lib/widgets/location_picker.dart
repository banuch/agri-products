import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../l10n/strings.dart';
import '../services/pincode_service.dart';

class LocationValue {
  const LocationValue({
    this.pincode = '',
    this.village = '',
    this.district = '',
    this.state = '',
  });

  final String pincode;
  final String village;
  final String district;
  final String state;

  bool get isComplete =>
      PincodeService.isValid(pincode) && district.trim().isNotEmpty && state.trim().isNotEmpty;
}

/// Pincode box that looks up the village list automatically once 6 digits
/// are typed, then fills District and State. Falls back to typing district
/// and state if the lookup cannot run (e.g. no internet).
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.onChanged,
    this.initial = const LocationValue(),
    this.required = true,
  });

  final ValueChanged<LocationValue> onChanged;
  final LocationValue initial;
  final bool required;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

enum _Mode { idle, loading, found, notFound, manual }

class _LocationPickerState extends State<LocationPicker> {
  late final TextEditingController _pin = TextEditingController(text: widget.initial.pincode);
  late final TextEditingController _district = TextEditingController(text: widget.initial.district);
  late final TextEditingController _state = TextEditingController(text: widget.initial.state);

  _Mode _mode = _Mode.idle;
  List<PostOffice> _places = const [];
  String _village = '';
  String _lookedUp = '';

  @override
  void initState() {
    super.initState();
    _village = widget.initial.village;
    if (widget.initial.pincode.isNotEmpty && widget.initial.district.isNotEmpty) {
      _mode = _Mode.manual; // editing an existing location: show the saved values
      _lookedUp = widget.initial.pincode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup(widget.initial.pincode, keepVillage: true));
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    _district.dispose();
    _state.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(LocationValue(
      pincode: _pin.text.trim(),
      village: _village,
      district: _district.text.trim(),
      state: _state.text.trim(),
    ));
  }

  Future<void> _lookup(String pin, {bool keepVillage = false}) async {
    _lookedUp = pin;
    setState(() => _mode = _Mode.loading);
    final result = await context.read<PincodeService>().lookup(pin);
    if (!mounted || _pin.text.trim() != pin) return;
    setState(() {
      switch (result.status) {
        case PincodeLookupStatus.found:
          _places = result.places;
          _mode = _Mode.found;
          final keep = keepVillage && _places.any((p) => p.name == _village);
          final chosen = keep
              ? _places.firstWhere((p) => p.name == _village)
              : _places.first;
          _village = chosen.name;
          _district.text = chosen.district;
          _state.text = chosen.state;
        case PincodeLookupStatus.notFound:
          _mode = _Mode.notFound;
          _places = const [];
          _village = '';
          _district.clear();
          _state.clear();
        case PincodeLookupStatus.failed:
          _mode = _Mode.manual;
      }
    });
    _emit();
  }

  void _onPinChanged(String v) {
    final pin = v.trim();
    if (pin.length == 6 && pin != _lookedUp) {
      _lookup(pin);
    } else if (pin.length < 6 && _mode != _Mode.idle) {
      setState(() {
        _mode = _Mode.idle;
        _lookedUp = '';
        _places = const [];
        _village = '';
        _district.clear();
        _state.clear();
      });
    }
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _pin,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          style: const TextStyle(fontSize: 22, letterSpacing: 4),
          decoration: InputDecoration(
            labelText: widget.required ? s.pincode : s.pincodeOptional,
            helperText: s.pincodeHelp,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.location_on, color: AppColors.green, size: 28),
          ),
          onChanged: _onPinChanged,
          validator: (v) {
            final pin = (v ?? '').trim();
            if (pin.isEmpty) return widget.required ? s.required : null;
            if (!PincodeService.isValid(pin)) return s.invalidPincode;
            if (_mode == _Mode.notFound) return s.pincodeNotFound;
            return null;
          },
        ),
        const SizedBox(height: 12),
        if (_mode == _Mode.loading)
          Row(children: [
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(width: 12),
            Text(s.findingPlace, style: const TextStyle(fontSize: 18)),
          ]),
        if (_mode == _Mode.notFound)
          Text(s.pincodeNotFound, style: const TextStyle(color: AppColors.danger, fontSize: 17)),
        if (_mode == _Mode.found) ...[
          DropdownButtonFormField<String>(
            initialValue: _village.isEmpty ? null : _village,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: s.villagePostOffice,
              prefixIcon: const Icon(Icons.home_work, color: AppColors.green, size: 28),
            ),
            hint: Text(s.selectVillage),
            items: _places
                .map((p) => DropdownMenuItem(value: p.name, child: Text(p.name, style: const TextStyle(fontSize: 19))))
                .toList(),
            onChanged: (v) {
              final p = _places.firstWhere((e) => e.name == v);
              setState(() {
                _village = p.name;
                _district.text = p.district;
                _state.text = p.state;
              });
              _emit();
            },
          ),
          const SizedBox(height: 12),
          _PlaceCard(district: _district.text, state: _state.text),
        ],
        if (_mode == _Mode.manual) ...[
          if (_places.isEmpty && _lookedUp.isNotEmpty && widget.initial.pincode != _lookedUp)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(s.pincodeLookupFailed, style: const TextStyle(fontSize: 16)),
            ),
          TextFormField(
            controller: _district,
            decoration: InputDecoration(
              labelText: s.district,
              prefixIcon: const Icon(Icons.map, color: AppColors.green),
            ),
            onChanged: (_) => _emit(),
            validator: (v) => widget.required && (v ?? '').trim().isEmpty ? s.required : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _state,
            decoration: InputDecoration(
              labelText: s.state,
              prefixIcon: const Icon(Icons.flag, color: AppColors.green),
            ),
            onChanged: (_) => _emit(),
            validator: (v) => widget.required && (v ?? '').trim().isEmpty ? s.required : null,
          ),
        ],
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.district, required this.state});

  final String district;
  final String state;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text('${s.district}: $district\n${s.state}: $state',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
