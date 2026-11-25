import 'package:cloud_firestore/cloud_firestore.dart';

class Enquiry {
  const Enquiry({
    this.id = '',
    required this.productId,
    required this.productNameEn,
    required this.productNameTe,
    required this.unit,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.quantity,
    this.message = '',
    this.status = 'new',
    this.createdAt,
  });

  final String id;
  final String productId;
  final String productNameEn;
  final String productNameTe;
  final String unit;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final double quantity;
  final String message;

  /// 'new' or 'responded'.
  final String status;
  final DateTime? createdAt;

  bool get isNew => status == 'new';

  String productName(bool telugu) {
    if (telugu) return productNameTe.isNotEmpty ? productNameTe : productNameEn;
    return productNameEn.isNotEmpty ? productNameEn : productNameTe;
  }

  factory Enquiry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? const <String, dynamic>{};
    return Enquiry(
      id: doc.id,
      productId: (m['productId'] ?? '') as String,
      productNameEn: (m['productNameEn'] ?? '') as String,
      productNameTe: (m['productNameTe'] ?? '') as String,
      unit: (m['unit'] ?? 'kg') as String,
      sellerId: (m['sellerId'] ?? '') as String,
      sellerName: (m['sellerName'] ?? '') as String,
      sellerPhone: (m['sellerPhone'] ?? '') as String,
      buyerId: (m['buyerId'] ?? '') as String,
      buyerName: (m['buyerName'] ?? '') as String,
      buyerPhone: (m['buyerPhone'] ?? '') as String,
      quantity: ((m['quantity'] ?? 0) as num).toDouble(),
      message: (m['message'] ?? '') as String,
      status: (m['status'] ?? 'new') as String,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'productId': productId,
        'productNameEn': productNameEn,
        'productNameTe': productNameTe,
        'unit': unit,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerPhone': sellerPhone,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerPhone': buyerPhone,
        'quantity': quantity,
        'message': message,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      };
}
