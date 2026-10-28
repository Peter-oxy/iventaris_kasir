import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('items');

  // STREAM (realtime) - tanpa orderBy, hanya where 1 field (tidak butuh index)
  Stream<List<ItemModel>> streamItems(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(ItemModel.fromDoc).toList());
  }

  // FUTURE (sekali ambil)
  Future<List<ItemModel>> getItems(String uid) async {
    final snap = await _col.where('uid', isEqualTo: uid).get();
    return snap.docs.map(ItemModel.fromDoc).toList();
  }

  Future<void> addItem(ItemModel item) => _col.add(item.toMap());

  Future<void> updateItem(ItemModel item) => _col.doc(item.id).update({
        'name': item.name,
        'stock': item.stock,
        'price': item.price,
      });

  Future<void> deleteItem(String id) => _col.doc(id).delete();
}