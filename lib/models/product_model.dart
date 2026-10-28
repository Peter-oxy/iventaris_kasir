class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double rating;
  final String thumbnail;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.rating,
    required this.thumbnail,
  });

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'],
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        category: j['category'] ?? '',
        brand: j['brand'] ?? '-',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        rating: (j['rating'] as num?)?.toDouble() ?? 0,
        thumbnail: j['thumbnail'] ?? '',
      );
}