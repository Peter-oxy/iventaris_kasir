import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'view_state.dart';

class ApiProvider extends ChangeNotifier {
  final ApiService _service = ApiService();

  ViewState state = ViewState.loading;
  List<ProductModel> products = [];
  String? errorMessage;

  ViewState detailState = ViewState.loading;
  ProductModel? detail;
  String? detailError;

  Future<void> fetchProducts() async {
    state = ViewState.loading;
    notifyListeners();
    try {
      products = await _service.getProducts();
      state = products.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> fetchDetail(int id) async {
    detailState = ViewState.loading;
    detail = null;
    notifyListeners();
    try {
      detail = await _service.getProduct(id);
      detailState = ViewState.loaded;
    } catch (e) {
      detailError = e.toString().replaceFirst('Exception: ', '');
      detailState = ViewState.error;
    }
    notifyListeners();
  }
}