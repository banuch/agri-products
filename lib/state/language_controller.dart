import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the chosen app language (Telugu or English) and remembers it.
class LanguageController extends ChangeNotifier {
  static const _key = 'app_language';

  String? _code; // 'te' or 'en'; null until the user picks one.

  bool get hasChosen => _code != null;
  bool get isTelugu => _code != 'en';
  Locale get locale => Locale(isTelugu ? 'te' : 'en');

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _code = prefs.getString(_key);
    } catch (_) {
      _code = null;
    }
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _code = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    } catch (_) {
      // Not fatal: the choice still applies for this session.
    }
  }
}
