import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../l10n/strings.dart';
import '../../models/product.dart';
import '../../services/data_service.dart';
import '../../state/session_controller.dart';
import '../../widgets/common.dart';
import '../buyer/product_detail_screen.dart' show NumberStepper;

/// Step-by-step Add/Edit Crop, one simple question per screen:
/// 1 Category → 2 Crop → 3 Photos → 4 Price & quantity → 5 Check & save.
class ProductWizard extends StatefulWidget {
  const ProductWizard({super.key, this.existing});

  final Product? existing;

  @override
  State<ProductWizard> createState() => _ProductWizardState();
}

class _ProductWizardState extends State<ProductWizard> {
  static const _steps = 5;
  static const _maxPhotos = 3;

  int _step = 0;
  String? _category;
  String? _cropKey;
  final _customName = TextEditingController();
  String _unit = 'kg';
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _desc = TextEditingController();
  List<String> _keptUrls = [];
  final List<String> _removedUrls = [];
  final List<File> _newPhotos = [];
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _category = p.category;
      _cropKey = Catalog.cropByKey(p.cropKey) == null ? Catalog.otherCropKey : p.cropKey;
      if (_cropKey == Catalog.otherCropKey) _customName.text = p.nameEn;
      _unit = p.unit;
      _price.text = formatNumber(p.price);
      _qty.text = formatNumber(p.quantity);
      _desc.text = p.description;
      _keptUrls = [...p.imageUrls];
      _step = 3; // jump straight to price & quantity when editing
    }
  }

  @override
  void dispose() {
    for (final c in [_customName, _price, _qty, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- helpers ----------
  Crop? get _crop => Catalog.cropByKey(_cropKey);
  double get _priceValue => double.tryParse(_price.text) ?? 0;
  double get _qtyValue => double.tryParse(_qty.text) ?? 0;
  int get _photoCount => _keptUrls.length + _newPhotos.length;

  String _cropLabel(S s) =>
      _cropKey == Catalog.otherCropKey ? _customName.text.trim() : (_crop?.name(s.isTelugu) ?? '');

  bool _canGoNext(S s) {
    switch (_step) {
      case 0:
        return _category != null;
      case 1:
        return _cropKey != null &&
            (_cropKey != Catalog.otherCropKey || _customName.text.trim().isNotEmpty);
      case 3:
        return _priceValue > 0 && _qtyValue > 0;
      default:
        return true;
    }
  }

  void _next() {
    final s = S.read(context);
    if (!_canGoNext(s)) {
      showMessage(context, _step == 3 ? s.invalidNumber : s.required, error: true);
      return;
    }
    if (_step < _steps - 1) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photoCount >= _maxPhotos) return;
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 1280, maxHeight: 1280, imageQuality: 70);
      if (x != null) setState(() => _newPhotos.add(File(x.path)));
    } catch (_) {
      if (mounted) showMessage(context, S.read(context).somethingWrong, error: true);
    }
  }

  Future<void> _save() async {
    final s = S.read(context);
    final me = context.read<SessionController>().user!;
    final crop = _crop;
    final isOther = _cropKey == Catalog.otherCropKey;
    final typed = _customName.text.trim();
    final product = Product(
      id: widget.existing?.id ?? '',
      sellerId: me.uid,
      sellerName: me.name,
      sellerPhone: me.phone,
      category: _category!,
      cropKey: isOther ? Catalog.otherCropKey : _cropKey,
      nameEn: isOther ? typed : crop!.en,
      nameTe: isOther ? typed : crop!.te,
      unit: _unit,
      price: _priceValue,
      quantity: _qtyValue,
      description: _desc.text.trim(),
      imageUrls: _keptUrls,
      pincode: me.pincode,
      village: me.village,
      district: me.district,
      state: me.state,
    );
    setState(() => _saving = true);
    try {
      await context
          .read<DataService>()
          .saveProduct(product, newImages: _newPhotos, removedUrls: _removedUrls);
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, s.saved);
    } catch (_) {
      if (mounted) showMessage(context, s.somethingWrong, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final titles = [s.step1Category, s.step2Crop, s.step3Photo, s.step4Price, s.step5Check];
    final last = _step == _steps - 1;

    return PopScope(
      canPop: _step == 0 && !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_saving) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? s.editCrop : s.addCrop),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _saving ? null : _back),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepDots(current: _step, total: _steps),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(titles[_step],
                    textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(child: _stepBody(s)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (_step > 0) ...[
                      Expanded(
                        child: BigButton(
                            icon: Icons.arrow_back, label: s.back, outlined: true, onPressed: _saving ? null : _back),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: last
                          ? BigButton(icon: Icons.check_circle, label: s.saveCrop, busy: _saving, onPressed: _save)
                          : BigButton(icon: Icons.arrow_forward, label: s.next, onPressed: _next),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody(S s) {
    switch (_step) {
      case 0:
        return _grid([
          for (final c in Catalog.categories)
            PictureTile(
              emoji: c.emoji,
              label: c.name(s.isTelugu),
              selected: _category == c.key,
              onTap: () => setState(() {
                if (_category != c.key) _cropKey = null;
                _category = c.key;
                _step = 1; // one tap moves on
              }),
            ),
        ]);
      case 1:
        return Column(
          children: [
            Expanded(
              child: _grid([
                for (final c in Catalog.cropsIn(_category!))
                  PictureTile(
                    emoji: c.emoji,
                    label: c.name(s.isTelugu),
                    selected: _cropKey == c.key,
                    onTap: () => setState(() {
                      _cropKey = c.key;
                      if (!_isEdit) _unit = c.unit;
                      _step = 2;
                    }),
                  ),
                PictureTile(
                  emoji: '➕',
                  label: s.otherCrop,
                  selected: _cropKey == Catalog.otherCropKey,
                  onTap: () => setState(() => _cropKey = Catalog.otherCropKey),
                ),
              ], columns: 3),
            ),
            if (_cropKey == Catalog.otherCropKey)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  controller: _customName,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: s.typeCropName,
                    prefixIcon: const Icon(Icons.edit, color: AppColors.green),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
          ],
        );
      case 2:
        return _photosStep(s);
      case 3:
        return _priceStep(s);
      default:
        return _reviewStep(s);
    }
  }

  Widget _grid(List<Widget> children, {int columns = 2}) => GridView.count(
        crossAxisCount: columns,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 2 ? 1.0 : 0.78,
        children: children,
      );

  Widget _photosStep(S s) {
    final emoji = _crop?.emoji ?? Catalog.categoryByKey(_category!).emoji;
    final thumbs = <Widget>[
      for (var i = 0; i < _keptUrls.length; i++)
        _PhotoThumb(
          child: ProductImage(url: _keptUrls[i], emoji: emoji, size: 100),
          onRemove: () => setState(() => _removedUrls.add(_keptUrls.removeAt(i))),
        ),
      for (var i = 0; i < _newPhotos.length; i++)
        _PhotoThumb(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_newPhotos[i], width: 100, height: 100, fit: BoxFit.cover),
          ),
          onRemove: () => setState(() => _newPhotos.removeAt(i)),
        ),
    ];
    final full = _photoCount >= _maxPhotos;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(s.photoHelp, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        if (thumbs.isEmpty)
          Center(child: Text('📷', style: const TextStyle(fontSize: 90)))
        else
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: thumbs),
        const SizedBox(height: 24),
        BigButton(
          icon: Icons.photo_camera,
          label: s.takePhoto,
          onPressed: full ? null : () => _pickPhoto(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        BigButton(
          icon: Icons.photo_library,
          label: s.fromGallery,
          outlined: true,
          onPressed: full ? null : () => _pickPhoto(ImageSource.gallery),
        ),
      ],
    );
  }

  void _bump(TextEditingController c, double delta) {
    final v = (double.tryParse(c.text) ?? 0) + delta;
    setState(() => c.text = formatNumber(v < 0 ? 0 : v));
  }

  Widget _priceStep(S s) {
    final unitName = s.unitName(_unit);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(s.unit, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final u in Catalog.units)
              ChoiceChip(
                label: Text(s.unitName(u), style: TextStyle(fontSize: 18, color: _unit == u ? Colors.white : AppColors.text)),
                selected: _unit == u,
                showCheckmark: false,
                selectedColor: AppColors.green,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                onSelected: (_) => setState(() => _unit = u),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(children: [
          const Text('💰', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 8),
          Expanded(child: Text(s.pricePer(unitName), style: Theme.of(context).textTheme.titleMedium)),
        ]),
        const SizedBox(height: 8),
        NumberStepper(
          controller: _price,
          prefix: '₹ ',
          onMinus: () => _bump(_price, -1),
          onPlus: () => _bump(_price, 1),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        Row(children: [
          const Text('⚖️', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 8),
          Expanded(child: Text(s.quantityAvailable, style: Theme.of(context).textTheme.titleMedium)),
        ]),
        const SizedBox(height: 8),
        NumberStepper(
          controller: _qty,
          suffix: unitName,
          onMinus: () => _bump(_qty, -1),
          onPlus: () => _bump(_qty, 1),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _desc,
          maxLines: 3,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            labelText: s.description,
            hintText: s.descriptionHint,
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewStep(S s) {
    final emoji = _crop?.emoji ?? Catalog.categoryByKey(_category!).emoji;
    final unitName = s.unitName(_unit);
    final firstPhoto = _newPhotos.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(_newPhotos.first, width: 160, height: 160, fit: BoxFit.cover))
        : ProductImage(url: _keptUrls.isEmpty ? null : _keptUrls.first, emoji: emoji, size: 160);

    Widget row(String emoji, String label, String value, int goToStep) => Card(
          elevation: 0,
          color: AppColors.greyCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Text(emoji, style: const TextStyle(fontSize: 32)),
            title: Text(label, style: const TextStyle(fontSize: 15)),
            subtitle: Text(value,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.text)),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: AppColors.green, size: 30),
              tooltip: s.edit,
              onPressed: () => setState(() => _step = goToStep),
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: firstPhoto),
        const SizedBox(height: 16),
        row(emoji, s.category, _cropLabel(s), 1),
        row('💰', s.price, '₹${formatNumber(_priceValue)} / $unitName', 3),
        row('⚖️', s.available, '${formatNumber(_qtyValue)} $unitName', 3),
        row('📷', s.step3Photo.split(':').last.trim(), '$_photoCount / $_maxPhotos', 2),
        if (_saving)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(s.uploading, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
          ),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final done = i < current;
          final active = i == current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || active ? AppColors.green : Colors.white,
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text('${i + 1}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: active ? Colors.white : AppColors.green)),
          );
        }),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(width: 100, height: 100, child: child),
        Positioned(
          right: -10,
          top: -10,
          child: Material(
            color: AppColors.danger,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
