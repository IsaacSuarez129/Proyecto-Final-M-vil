import 'package:pvm/core/config/supabase_config.dart';
import 'package:pvm/core/errors/app_exception.dart';
import 'package:pvm/features/catalog/domain/entities/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  const ProductRepository();

  static const String _table = 'products';

  Future<List<Product>> fetchProducts() async {
    final rows = await SupabaseConfig.client.from(_table).select().order('name');
    return rows.map(Product.fromJson).toList();
  }

  Future<void> createProduct(ProductData data) {
    return _run(() async {
      await SupabaseConfig.client.from(_table).insert(_toRow(data));
    });
  }

  Future<void> updateProduct(String id, ProductData data) {
    return _run(() async {
      await SupabaseConfig.client.from(_table).update(_toRow(data)).eq('id', id);
    });
  }

  Future<void> deleteProduct(String id) async {
    await SupabaseConfig.client.from(_table).delete().eq('id', id);
  }

  Map<String, dynamic> _toRow(ProductData data) {
    return {
      'name': data.name,
      'price': data.price,
      'code': data.code,
      'code_type': data.codeType.name,
      'category': data.category,
      'subcategory': data.subcategory,
    };
  }

  // Convierte el error de "código duplicado" en un mensaje claro.
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppException('Ya existe un producto con ese código.');
      }
      rethrow;
    }
  }
}