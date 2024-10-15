class ProductModel {
  late String productName,
      productCategory,
      size,
      color,
      weight,
      capacity,
      type,
      warranty,
      brandName,
      productCode,
      productStock,
      productUnit,
      productSalePrice,
      productPurchasePrice,
      productDiscount,
      productWholeSalePrice,
      productMrp,
      gstType,
      productPicture,
      gstAmount,
      hsnSAC;
  List<String> serialNumber = [];

  ProductModel({
    required this.productName,
    required this.productCategory,
    required this.size,
    required this.color,
    required this.weight,
    required this.capacity,
    required this.type,
    required this.warranty,
    required this.brandName,
    required this.productCode,
    required this.productStock,
    required this.productUnit,
    required this.productSalePrice,
    required this.productPurchasePrice,
    required this.productDiscount,
    required this.productWholeSalePrice,
    required this.productMrp,
    required this.gstType,
    required this.productPicture,
    required this.serialNumber,
    required this.hsnSAC,
    required this.gstAmount
  });

  ProductModel.fromJson(Map<dynamic, dynamic> json) {
    productName = json['productName'] as String;
    productCategory = json['productCategory'].toString();
    size = json['size'].toString();
    color = json['color'].toString();
    weight = json['weight'].toString();
    capacity = json['capacity'].toString();
    type = json['type'].toString();
    warranty = json['warranty'].toString();
    brandName = json['brandName'].toString();
    productCode = json['productCode'].toString();
    productStock = json['productStock'].toString();
    productUnit = json['productUnit'].toString();
    productSalePrice = json['productSalePrice'].toString();
    productPurchasePrice = json['productPurchasePrice'].toString();
    productDiscount = json['productDiscount'].toString();
    productWholeSalePrice = json['productWholeSalePrice'].toString();
    productMrp = json['productMrp'].toString();
    gstType = json['gstType'].toString();
    gstAmount=json['gstAmount'].toString();
    productPicture = json['productPicture'].toString();
    hsnSAC = json['HSNSAC'].toString();
    if (json['serialNumber'] != null) {
      serialNumber = <String>[];
      json['serialNumber'].forEach((v) {
        serialNumber.add(v);
      });
    }
  }

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'productName': productName,
        'productCategory': productCategory,
        'size': size,
        'color': color,
        'weight': weight,
        'capacity': capacity,
        'type': type,
        'warranty': warranty,
        'brandName': brandName,
        'productCode': productCode,
        'productStock': productStock,
        'productUnit': productUnit,
        'productSalePrice': productSalePrice,
        'productPurchasePrice': productPurchasePrice,
        'productDiscount': productDiscount,
        'productWholeSalePrice': productWholeSalePrice,
        'productMrp': productMrp,
        'gstType': gstType,
          'gstAmount':gstAmount,
        'productPicture': productPicture,
        'HSNSAC': hsnSAC,
        'serialNumber': serialNumber.map((e) => e).toList(),
      };
}
