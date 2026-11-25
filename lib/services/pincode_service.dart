import 'dart:convert';

import 'package:http/http.dart' as http;

class PostOffice {
  const PostOffice({required this.name, required this.district, required this.state});
  final String name;
  final String district;
  final String state;
}

enum PincodeLookupStatus { found, notFound, failed }

class PincodeLookup {
  const PincodeLookup(this.status, [this.places = const []]);
  final PincodeLookupStatus status;
  final List<PostOffice> places;
}

/// Looks up villages/post offices for an Indian pincode using the public
/// India Post API (https://api.postalpincode.in).
class PincodeService {
  PincodeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, PincodeLookup> _cache = {};

  static bool isValid(String pincode) => RegExp(r'^[1-9][0-9]{5}$').hasMatch(pincode);

  Future<PincodeLookup> lookup(String pincode) async {
    if (!isValid(pincode)) return const PincodeLookup(PincodeLookupStatus.notFound);
    final cached = _cache[pincode];
    if (cached != null) return cached;
    try {
      final res = await _client
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const PincodeLookup(PincodeLookupStatus.failed);
      final result = parse(res.body);
      if (result.status != PincodeLookupStatus.failed) _cache[pincode] = result;
      return result;
    } catch (_) {
      return const PincodeLookup(PincodeLookupStatus.failed);
    }
  }

  /// Parses the API body. Exposed for tests.
  static PincodeLookup parse(String body) {
    try {
      final data = jsonDecode(body);
      if (data is! List || data.isEmpty) {
        return const PincodeLookup(PincodeLookupStatus.failed);
      }
      final first = data.first as Map<String, dynamic>;
      final offices = first['PostOffice'];
      if (first['Status'] != 'Success' || offices is! List || offices.isEmpty) {
        return const PincodeLookup(PincodeLookupStatus.notFound);
      }
      final places = offices
          .whereType<Map<String, dynamic>>()
          .map((o) => PostOffice(
                name: (o['Name'] ?? '').toString(),
                district: (o['District'] ?? '').toString(),
                state: (o['State'] ?? '').toString(),
              ))
          .where((p) => p.name.isNotEmpty)
          .toList();
      return places.isEmpty
          ? const PincodeLookup(PincodeLookupStatus.notFound)
          : PincodeLookup(PincodeLookupStatus.found, places);
    } catch (_) {
      return const PincodeLookup(PincodeLookupStatus.failed);
    }
  }
}
