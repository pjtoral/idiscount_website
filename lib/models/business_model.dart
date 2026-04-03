// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

enum Category {
  ALL,
  FOOD,
  FASHION,
  HEALTH,
  BEAUTY,
  EDUCATION,
  TECH,
  TRAVEL,
  SERVICES,
  OTHER;

  String toShortString() {
    switch (this) {
      case Category.ALL:
        return 'All';
      case Category.FOOD:
        return 'Food';
      case Category.FASHION:
        return 'Fashion';
      case Category.HEALTH:
        return 'Health';
      case Category.BEAUTY:
        return 'Beauty';
      case Category.EDUCATION:
        return 'Education';
      case Category.TECH:
        return 'Tech';
      case Category.TRAVEL:
        return 'Travel';
      case Category.SERVICES:
        return 'Services';
      case Category.OTHER:
        return 'Other';
    }
  }

  static Category fromString(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'all':
        return Category.ALL;
      case 'food':
        return Category.FOOD;
      case 'fashion':
        return Category.FASHION;
      case 'health':
        return Category.HEALTH;
      case 'beauty':
        return Category.BEAUTY;
      case 'education':
        return Category.EDUCATION;
      case 'tech':
      case 'technology':
        return Category.TECH;
      case 'travel':
        return Category.TRAVEL;
      case 'services':
        return Category.SERVICES;
      default:
        return Category.OTHER;
    }
  }
}

class BusinessModel {
  final int uid;
  final String companyName;
  final Category category;
  final String discount;
  final String website;
  final String facebook;
  final String instagram;
  final String tiktok;
  final String x;
  final String group;
  final DateTime? validity;
  final String idPhoto;
  final List<BusinessBranchModel> addresses;

  BusinessModel({
    required this.uid,
    required this.companyName,
    required this.category,
    required this.discount,
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.tiktok,
    required this.x,
    required this.group,
    required this.validity,
    required this.idPhoto,
    required this.addresses,
  });

  factory BusinessModel.merge({
    required BusinessDetailsModel base,
    List<BusinessBranchModel>? branches,
  }) {
    return BusinessModel(
      uid: base.uid,
      companyName: base.companyName,
      category: base.category,
      discount: base.discount,
      website: base.website,
      facebook: base.facebook,
      instagram: base.instagram,
      tiktok: base.tiktok,
      x: base.x,
      group: base.group,
      validity: base.validity,
      idPhoto: base.idPhoto,
      addresses: branches ?? [],
    );
  }
}

class BusinessDetailsModel {
  int uid;
  String companyName;
  Category category;
  String discount;
  String website;
  String facebook;
  String instagram;
  String tiktok;
  String x;
  String group;
  DateTime? validity;
  bool isFeatured;
  String idPhoto;

  BusinessDetailsModel({
    required this.uid,
    required this.companyName,
    required this.category,
    required this.discount,
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.tiktok,
    required this.x,
    required this.group,
    required this.validity,
    required this.isFeatured,
    required this.idPhoto,
  });

  factory BusinessDetailsModel.fromJson(Map<String, dynamic> json) {
    final imageRef = json['business_image']?.toString() ?? '';
    final imageUrl =
        imageRef.isNotEmpty && imageRef.startsWith('http')
            ? imageRef
            : imageRef.isNotEmpty
            ? 'https://yfcbtbivhuslzxzqcnve.supabase.co/storage/v1/object/public/business-registrations/$imageRef'
            : '';

    DateTime? validityDate;
    final validityString = (json['validity'] ?? '').toString().trim();
    if (validityString.isNotEmpty) {
      try {
        validityDate = DateFormat('dd/MM/yyyy').parseStrict(validityString);
      } catch (_) {
        validityDate = DateTime.tryParse(validityString);
      }
    }

    return BusinessDetailsModel(
      uid:
          json['uid'] is int
              ? json['uid']
              : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      category: Category.fromString(json['category']?.toString() ?? ''),
      discount: json['discount']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      facebook: json['facebook']?.toString() ?? '',
      instagram: json['instagram']?.toString() ?? '',
      tiktok: json['tiktok']?.toString() ?? '',
      x: json['x']?.toString() ?? '',
      group: json['group_name']?.toString() ?? 'All',
      validity: validityDate,
      isFeatured:
          json['is_featured'] is bool
              ? json['is_featured']
              : (json['is_featured'] == 1),
      idPhoto: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'company_name': companyName,
      'category': category.toShortString(),
      'discount': discount,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'x': x,
      'group_name': group,
      'validity':
          validity != null ? DateFormat('dd/MM/yyyy').format(validity!) : null,
      'is_featured': isFeatured,
      'business_image': idPhoto,
    };
  }
}

class BusinessBranchModel {
  final int locationUid;
  final int uid;
  final String companyName;
  final String fullAddress;
  final String cityMunicipality;
  final String province;
  final double latitude;
  final double longitude;

  BusinessBranchModel({
    required this.locationUid,
    required this.uid,
    required this.companyName,
    required this.fullAddress,
    required this.cityMunicipality,
    required this.province,
    required this.latitude,
    required this.longitude,
  });

  factory BusinessBranchModel.fromJson(Map<String, dynamic> json) {
    return BusinessBranchModel(
      locationUid:
          json['location_uid'] is int
              ? json['location_uid']
              : int.tryParse(json['location_uid']?.toString() ?? '0') ?? 0,
      uid:
          json['uid'] is int
              ? json['uid']
              : int.tryParse(json['uid']?.toString() ?? '0') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      cityMunicipality: json['city_municipality']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      latitude:
          json['latitude'] is double
              ? json['latitude']
              : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude:
          json['longitude'] is double
              ? json['longitude']
              : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
    );
  }
}
