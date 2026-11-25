import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';
import '../models/enquiry.dart';
import '../models/product.dart';

/// Location filter used on buyer product lists.
class PlaceFilter {
  const PlaceFilter.all()
      : field = null,
        value = null;
  const PlaceFilter.district(String d)
      : field = 'district',
        value = d;
  const PlaceFilter.pincode(String p)
      : field = 'pincode',
        value = p;

  final String? field;
  final String? value;

  bool get isAll => field == null;
}

/// Firestore + Storage access for users, products and enquiries.
///
/// Queries use only equality filters and sort on the device, so no
/// composite Firestore indexes are needed.
class DataService {
  DataService({FirebaseFirestore? db, FirebaseStorage? storage})
      : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _products => _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _enquiries => _db.collection('enquiries');

  // ---------------- Users ----------------
  Stream<AppUser?> watchUser(String uid) => _users.doc(uid).snapshots().map(
      (d) => d.exists ? AppUser.fromMap(d.id, d.data()!) : null);

  Future<AppUser?> getUser(String uid) async {
    final d = await _users.doc(uid).get();
    return d.exists ? AppUser.fromMap(d.id, d.data()!) : null;
  }

  /// Updates the profile and copies the new location/name onto the
  /// seller's products so buyer filters stay correct.
  Future<void> updateUser(AppUser user) async {
    await _users.doc(user.uid).update(user.toMap());
    if (!user.isSeller) return;
    final mine = await _products.where('sellerId', isEqualTo: user.uid).get();
    final batch = _db.batch();
    for (final d in mine.docs) {
      batch.update(d.reference, {
        'sellerName': user.name,
        'pincode': user.pincode,
        'village': user.village,
        'district': user.district,
        'state': user.state,
      });
    }
    await batch.commit();
  }

  // ---------------- Products ----------------
  static List<Product> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map(Product.fromDoc).toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(2100))
        .compareTo(a.createdAt ?? DateTime(2100)));
    return list;
  }

  Stream<List<Product>> watchProducts({String? category, PlaceFilter filter = const PlaceFilter.all()}) {
    Query<Map<String, dynamic>> q = _products;
    if (category != null) q = q.where('category', isEqualTo: category);
    if (!filter.isAll) q = q.where(filter.field!, isEqualTo: filter.value);
    return q.limit(300).snapshots().map(_sorted);
  }

  Stream<List<Product>> watchSellerProducts(String sellerId) => _products
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .map(_sorted);

  Stream<Product?> watchProduct(String id) => _products
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Product.fromDoc(d) : null);

  /// Creates or updates a product. [newImages] are uploaded and added after
  /// [product.imageUrls]; [removedUrls] are deleted from Storage.
  Future<void> saveProduct(
    Product product, {
    List<File> newImages = const [],
    List<String> removedUrls = const [],
  }) async {
    final doc = product.id.isEmpty ? _products.doc() : _products.doc(product.id);
    final urls = [...product.imageUrls];
    for (var i = 0; i < newImages.length; i++) {
      final ref = _storage.ref(
          'products/${product.sellerId}/${doc.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      await ref.putFile(newImages[i], SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await ref.getDownloadURL());
    }
    final data = product.copyWith(imageUrls: urls).toMap();
    if (product.id.isEmpty) {
      await doc.set({...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await doc.update(data);
    }
    await _deleteImages(removedUrls);
  }

  Future<void> deleteProduct(Product product) async {
    await _products.doc(product.id).delete();
    await _deleteImages(product.imageUrls);
  }

  Future<void> _deleteImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {
        // Best effort: a leftover photo is harmless.
      }
    }
  }

  // ---------------- Enquiries ----------------
  static List<Enquiry> _sortedEnq(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map(Enquiry.fromDoc).toList();
    list.sort((a, b) => (b.createdAt ?? DateTime(2100))
        .compareTo(a.createdAt ?? DateTime(2100)));
    return list;
  }

  Future<void> sendEnquiry(Enquiry e) => _enquiries.add(e.toCreateMap());

  Stream<List<Enquiry>> watchSellerEnquiries(String sellerId) => _enquiries
      .where('sellerId', isEqualTo: sellerId)
      .snapshots()
      .map(_sortedEnq);

  Stream<List<Enquiry>> watchBuyerEnquiries(String buyerId) => _enquiries
      .where('buyerId', isEqualTo: buyerId)
      .snapshots()
      .map(_sortedEnq);

  Future<void> markResponded(String enquiryId) =>
      _enquiries.doc(enquiryId).update({'status': 'responded'});
}
