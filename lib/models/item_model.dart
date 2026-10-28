import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final int stock;
  final double price;
  final DateTime createdAt;
  final String uid; // pemilik data

  ItemModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    required this.createdAt,
    required this.uid,
  });

  factory ItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ItemModel(
      id: doc.id,
      name: d['name'] ?? '',
      stock: (d['stock'] as num?)?.toInt() ?? 0,
      price: (d['price'] as num?)?.toDouble() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      uid: d['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'stock': stock,
        'price': price,
        'createdAt': Timestamp.fromDate(createdAt), // field bertipe Timestamp
        'uid': uid,
      };
}
// ===== Helper format (dipakai di semua layar) =====
const double kKursUsdKeRp = 18000; // ubah sesuai kebutuhan

String rupiah(num value) {
  final s = value.round().abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}Rp ${buf.toString()}';
}