import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<ProductModel>> getProducts({int limit = 30}) async {
    try {
      final res = await _dio.get('/products', queryParameters: {'limit': limit});
      final list = res.data['products'] as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final res = await _dio.get('/products/$id');
      return ProductModel.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(_msg(e));
    }
  }

  String _msg(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout, coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet.';
      default:
        return 'Gagal memuat data (${e.response?.statusCode ?? 'unknown'}).';
    }
  }
}