import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller }

class AppUser {
  const AppUser({
    required this.uid,
    required this.role,
    required this.name,
    required this.phone,
    this.pincode = '',
    this.village = '',
    this.district = '',
    this.state = '',
    this.address = '',
  });

  final String uid;
  final UserRole role;
  final String name;
  final String phone;
  final String pincode;
  final String village;
  final String district;
  final String state;
  final String address;

  bool get isSeller => role == UserRole.seller;

  /// "Village, District" style short location for display.
  String get placeLine =>
      [village, district].where((e) => e.trim().isNotEmpty).join(', ');

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        role: m['role'] == 'seller' ? UserRole.seller : UserRole.buyer,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        pincode: (m['pincode'] ?? '') as String,
        village: (m['village'] ?? '') as String,
        district: (m['district'] ?? '') as String,
        state: (m['state'] ?? '') as String,
        address: (m['address'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'name': name,
        'phone': phone,
        'pincode': pincode,
        'village': village,
        'district': district,
        'state': state,
        'address': address,
      };

  Map<String, dynamic> toCreateMap() =>
      {...toMap(), 'createdAt': FieldValue.serverTimestamp()};

  AppUser copyWith({
    String? name,
    String? pincode,
    String? village,
    String? district,
    String? state,
    String? address,
  }) =>
      AppUser(
        uid: uid,
        role: role,
        name: name ?? this.name,
        phone: phone,
        pincode: pincode ?? this.pincode,
        village: village ?? this.village,
        district: district ?? this.district,
        state: state ?? this.state,
        address: address ?? this.address,
      );
}
