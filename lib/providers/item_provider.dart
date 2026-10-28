import 'dart:async';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import 'view_state.dart';

class ItemProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  StreamSubscription<List<ItemModel>>? _sub;

  ViewState state = ViewState.loading;
  List<ItemModel> items = [];
  String? errorMessage;

  void listen(String uid) {
    _sub?.cancel();
    state = ViewState.loading;
    notifyListeners();

    _sub = _service.streamItems(uid).listen(
      (data) {
        // Sorting di sisi client (Dart), bukan orderBy Firestore
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        items = data;
        state = data.isEmpty ? ViewState.empty : ViewState.loaded;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = e.toString();
        state = ViewState.error;
        notifyListeners();
      },
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    items = [];
    state = ViewState.loading;
  }

  Future<void> add(String uid, String name, int stock, double price) =>
      _service.addItem(ItemModel(
        id: '',
        name: name,
        stock: stock,
        price: price,
        createdAt: DateTime.now(),
        uid: uid,
      ));

  Future<void> update(ItemModel item) => _service.updateItem(item);
  Future<void> delete(String id) => _service.deleteItem(id);

  // Contoh pemakaian FUTURE get() untuk penjelasan di video
  Future<int> countOnce(String uid) async =>
      (await _service.getItems(uid)).length;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}