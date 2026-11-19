enum CodeType { barcode, pos }

// Datos que captura el formulario para crear o actualizar un producto.
typedef ProductData = ({
  String name,
  double price,
  String code,
  CodeType codeType,
  String category,
  String? subcategory,
});

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.code,
    required this.codeType,
    required this.category,
    this.subcategory,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      code: json['code'] as String,
      codeType: json['code_type'] == 'pos' ? CodeType.pos : CodeType.barcode,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
    );
  }

  final String id;
  final String name;
  final double price;
  final String code;
  final CodeType codeType;
  final String category;
  final String? subcategory;

   // Cada palabra de [query] debe aparecer en el nombre o en el código.
  bool matchesSearch(String query) {
    final haystack = _normalize('$name $code');
    final terms = _normalize(query).split(' ').where((term) => term.isNotEmpty);
    return terms.every((term) => haystack.contains(term));
  }
}

// Minúsculas y sin acentos, para que "Maria" encuentre "María".
String _normalize(String text) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';

  var result = text.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    result = result.replaceAll(from[i], to[i]);
  }
  return result;
}