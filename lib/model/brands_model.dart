class BrandsModel {
  late String brandName;

  BrandsModel({required this.brandName});

  BrandsModel.fromJson(Map<dynamic, dynamic> json) : brandName = json['brandName'] as String;

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'brandName': brandName,
      };
}
