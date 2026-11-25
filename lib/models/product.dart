import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/catalog.dart';

class Product {
  const Product({
    this.id = '',
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.category,
    this.cropKey,
    required this.nameEn,
    required this.nameTe,
    required this.unit,
    required this.price,
    required this.quantity,
    this.description = '',
    this.imageUrls = const [],
    required this.pincode,
    this.village = '',
    this.district = '',
    this.state = '',
    this.createdAt,
  });

  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String category;

  /// Key from [Catalog.crops], or null/'other' for a typed name.
  final String? cropKey;
  final String nameEn;
  final String nameTe;

  /// One of [Catalog.units].
  final String unit;

  /// Price in rupees for one [unit].
  final double price;

  /// Quantity available, in [unit]s.
  final double quantity;
  final String description;
  final List<String> imageUrls;
  final String pincode;
  final String village;
  final String district;
  final String state;
  final DateTime? createdAt;

  String displayName(bool telugu) {
    if (telugu) return nameTe.isNotEmpty ? nameTe : nameEn;
    return nameEn.isNotEmpty ? nameEn : nameTe;
  }

  String get emoji =>
      Catalog.cropByKey(cropKey)?.emoji ?? Catalog.categoryByKey(category).emoji;

  String get placeLine =>
      [village, district].where((e) => e.trim().isNotEmpty).join(', ');

  /// True if [query] matches the English or Telugu name.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return nameEn.toLowerCase().contains(q) || nameTe.contains(q);
  }

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Product.fromMap(doc.id, doc.data() ?? const {});

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
        id: id,
        sellerId: (m['sellerId'] ?? '') as String,
        sellerName: (m['sellerName'] ?? '') as String,
        sellerPhone: (m['sellerPhone'] ?? '') as String,
        category: (m['category'] ?? 'dairy_others') as String,
        cropKey: m['cropKey'] as String?,
        nameEn: (m['nameEn'] ?? '') as String,
        nameTe: (m['nameTe'] ?? '') as String,
        unit: (m['unit'] ?? 'kg') as String,
        price: ((m['price'] ?? 0) as num).toDouble(),
        quantity: ((m['quantity'] ?? 0) as num).toDouble(),
        description: (m['description'] ?? '') as String,
        imageUrls: List<String>.from((m['imageUrls'] ?? const []) as List),
        pincode: (m['pincode'] ?? '') as String,
        village: (m['village'] ?? '') as String,
        district: (m['district'] ?? '') as String,
        state: (m['state'] ?? '') as String,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      );

  Map<String, dynamic> toMap() => {
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerPhone': sellerPhone,
        'category': category,
        'cropKey': cropKey,
        'nameEn': nameEn,
        'nameTe': nameTe,
        'unit': unit,
        'price': price,
        'quantity': quantity,
        'description': description,
        'imageUrls': imageUrls,
        'pincode': pincode,
        'village': village,
        'district': district,
        'state': state,
      };

  Product copyWith({String? id, List<String>? imageUrls}) => Product(
        id: id ?? this.id,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerPhone: sellerPhone,
        category: category,
        cropKey: cropKey,
        nameEn: nameEn,
        nameTe: nameTe,
        unit: unit,
        price: price,
        quantity: quantity,
        description: description,
        imageUrls: imageUrls ?? this.imageUrls,
        pincode: pincode,
        village: village,
        district: district,
        state: state,
        createdAt: createdAt,
      );
}

/// Formats 25.0 as "25" and 2.5 as "2.5".
String formatNumber(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
