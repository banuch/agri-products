import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../l10n/strings.dart';
import '../state/language_controller.dart';

/// Big pill button that always shows an icon next to the text, so it can be
/// recognised without reading.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.color,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color? color;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            height: 26, width: 26, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
        // Shrink the whole label to fit instead of wrapping letter by letter
        // in narrow buttons or with large system font sizes.
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 10),
                Text(label, maxLines: 1, softWrap: false),
              ],
            ),
          );
    if (outlined) {
      return OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: color == null
            ? null
            : OutlinedButton.styleFrom(
                foregroundColor: color, side: BorderSide(color: color!, width: 2)),
        child: child,
      );
    }
    return ElevatedButton(
      onPressed: busy ? null : onPressed,
      style: color == null ? null : ElevatedButton.styleFrom(backgroundColor: color),
      child: child,
    );
  }
}

/// Square card with a large picture (emoji) and a label underneath.
class PictureTile extends StatelessWidget {
  const PictureTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          // The picture takes whatever space the label leaves, so the tile
          // never overflows on small screens or with large fonts.
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: icon != null
                      ? Icon(icon, size: 54, color: selected ? Colors.white : AppColors.green)
                      : Text(emoji, style: const TextStyle(fontSize: 54)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product photo, or a big emoji when there is no photo.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.url, required this.emoji, this.size = 72, this.fit = BoxFit.cover});

  final String? url;
  final String emoji;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: fit,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(S.of(context).loading, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.emoji, required this.message, this.action});

  final String emoji;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Small "తెలుగు / English" switch for app bars.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    return TextButton.icon(
      onPressed: () => lang.setLanguage(lang.isTelugu ? 'en' : 'te'),
      icon: const Icon(Icons.translate, color: AppColors.green),
      label: Text(lang.isTelugu ? 'English' : 'తెలుగు',
          style: const TextStyle(color: AppColors.green, fontSize: 16)),
    );
  }
}

/// Simple yes/no dialog with big icon buttons. Returns true for yes.
Future<bool> confirm(BuildContext context, String question, {bool danger = false}) async {
  final s = S.read(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(question, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: BigButton(
                icon: Icons.close,
                label: s.no,
                outlined: true,
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BigButton(
                icon: Icons.check,
                label: s.yes,
                color: danger ? AppColors.danger : null,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline : Icons.check_circle, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ]),
      backgroundColor: error ? AppColors.danger : AppColors.greenDark,
    ));
}

Future<void> callNumber(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  final number = digits.startsWith('+') || digits.length != 10 ? digits : '+91$digits';
  await launchUrl(Uri(scheme: 'tel', path: number));
}

/// Fills the screen like a plain Column (so `Spacer`s work on tall phones)
/// but scrolls instead of overflowing on short phones / large fonts.
class FillScroll extends StatelessWidget {
  const FillScroll({super.key, required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight - padding.vertical),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

/// Card used for grouping details on detail/account screens.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 19))),
        ],
      ),
    );
  }
}
