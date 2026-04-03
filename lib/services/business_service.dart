import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_category.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/models/business_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  final _supabase = Supabase.instance.client;

  BusinessService._internal();

  factory BusinessService() {
    return _instance;
  }

  static const String _businessPhotosBucket = 'business-registrations';

  Future<int?> _resolveCurrentUserBusinessId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final metadataValue = user.userMetadata?['business_uid'];
    if (metadataValue is int) return metadataValue;
    if (metadataValue is num) return metadataValue.toInt();
    if (metadataValue is String) {
      return int.tryParse(metadataValue);
    }

    return null;
  }

  Future<void> _saveCurrentUserBusinessId(int businessId) async {
    await _supabase.auth.updateUser(
      UserAttributes(data: {'business_uid': businessId}),
    );
  }

  int _generateBusinessUid() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  int _generateLocationUid(int businessId, int index) {
    return (businessId * 1000) + index;
  }

  String _buildValidity(DateTime startDate, DateTime? endDate, bool isOngoing) {
    final sourceDate = (!isOngoing && endDate != null) ? endDate : startDate;
    final day = sourceDate.day.toString().padLeft(2, '0');
    final month = sourceDate.month.toString().padLeft(2, '0');
    final year = sourceDate.year.toString();
    return '$day/$month/$year';
  }

  String _buildDiscountText(String discountType, double discountAmount) {
    if (discountType.toLowerCase() == 'percentage') {
      return '${discountAmount.toStringAsFixed(discountAmount % 1 == 0 ? 0 : 2)}%';
    }
    return '₱${discountAmount.toStringAsFixed(discountAmount % 1 == 0 ? 0 : 2)}';
  }

  (String type, double amount) _parseDiscount(String? discountText) {
    final input = (discountText ?? '').trim();
    if (input.isEmpty) return ('percentage', 0.0);

    final numberMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(input);
    final double amount =
        numberMatch != null
            ? double.tryParse(numberMatch.group(1) ?? '0') ?? 0.0
            : 0.0;

    if (input.contains('%')) {
      return ('percentage', amount);
    }
    return ('fixed', amount);
  }

  DateTime? _parseValidityDate(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;

    final slashParts = text.split('/');
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(text);
  }

  Future<void> _upsertBusinessData({
    required int businessUid,
    required String businessName,
    String? categoryCode,
    String? category,
    required List<String> locations,
    required String discountType,
    required double discountAmount,
    required bool offerToAllSchools,
    required List<String> selectedSchools,
    required DateTime startDate,
    DateTime? endDate,
    bool isOngoing = false,
    String? website,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? x,
    String? cityMunicipality,
    String? province,
    double? latitude,
    double? longitude,
    String? businessImageUrl,
  }) async {
    final existing =
        await _supabase
            .from('business_names')
            .select('uid')
            .eq('uid', businessUid)
            .maybeSingle();

    final businessPayload = {
      'uid': businessUid,
      'company_name': businessName,
      'category_code': categoryCode,
      'category': category,
      'discount': _buildDiscountText(discountType, discountAmount),
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'x': x,
      'group_name':
          offerToAllSchools ? 'All Schools' : selectedSchools.join(', '),
      'validity': _buildValidity(startDate, endDate, isOngoing),
      'business_image': businessImageUrl,
    };

    if (existing == null) {
      await _supabase.from('business_names').insert(businessPayload);
    } else {
      await _supabase
          .from('business_names')
          .update(businessPayload)
          .eq('uid', businessUid);
    }

    await _supabase.from('business_addresses').delete().eq('uid', businessUid);
    for (var i = 0; i < locations.length; i++) {
      await _supabase.from('business_addresses').insert({
        'location_uid': _generateLocationUid(businessUid, i + 1),
        'uid': businessUid,
        'company_name': businessName,
        'full_address': locations[i],
        'city_municipality': cityMunicipality,
        'province': province,
        'latitude': latitude,
        'longitude': longitude,
      });
    }

    await _saveCurrentUserBusinessId(businessUid);
  }

  Future<void> saveDraft({
    required String businessName,
    String? categoryCode,
    String? category,
    required List<String> locations,
    required String discountType,
    required double discountAmount,
    required bool offerToAllSchools,
    required List<String> selectedSchools,
    required DateTime startDate,
    DateTime? endDate,
    bool isOngoing = false,
    String? website,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? x,
    String? cityMunicipality,
    String? province,
    double? latitude,
    double? longitude,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final businessUid =
        await _resolveCurrentUserBusinessId() ?? _generateBusinessUid();

    await _upsertBusinessData(
      businessUid: businessUid,
      businessName: businessName,
      categoryCode: categoryCode,
      category: category,
      locations: locations,
      discountType: discountType,
      discountAmount: discountAmount,
      offerToAllSchools: offerToAllSchools,
      selectedSchools: selectedSchools,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      website: website,
      facebook: facebook,
      instagram: instagram,
      tiktok: tiktok,
      x: x,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    return await getLatestRegistrationRecord();
  }

  Future<bool> hasCompletedRegistration() async {
    final businessId = await _resolveCurrentUserBusinessId();
    if (businessId == null) return false;

    final existing =
        await _supabase
            .from('business_names')
            .select('uid')
            .eq('uid', businessId)
            .maybeSingle();
    return existing != null;
  }

  Future<void> submitBusinessRegistration({
    required String businessName,
    String? categoryCode,
    String? category,
    required List<String> locations,
    required String discountType,
    required double discountAmount,
    required bool offerToAllSchools,
    required List<String> selectedSchools,
    required DateTime startDate,
    DateTime? endDate,
    bool isOngoing = false,
    String? website,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? x,
    String? cityMunicipality,
    String? province,
    double? latitude,
    double? longitude,
    String? photoFileName,
    Uint8List? photoData,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String? photoUrl;

    if (photoData != null && photoFileName != null) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final safeFileName =
            photoFileName
                .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
                .toLowerCase();
        final storagePath =
            'business_photos/${user.id}/$timestamp-$safeFileName';

        await _supabase.storage
            .from(_businessPhotosBucket)
            .uploadBinary(storagePath, photoData);

        photoUrl = _supabase.storage
            .from(_businessPhotosBucket)
            .getPublicUrl(storagePath);
      } on StorageException catch (e) {
        throw Exception(
          'Photo upload failed (${e.statusCode}): ${e.message}. '
          'Check Storage bucket "$_businessPhotosBucket" and RLS INSERT policy for storage.objects.',
        );
      } catch (e) {
        throw Exception('Photo upload failed: $e');
      }
    }

    final businessUid =
        await _resolveCurrentUserBusinessId() ?? _generateBusinessUid();

    await _upsertBusinessData(
      businessUid: businessUid,
      businessName: businessName,
      categoryCode: categoryCode,
      category: category,
      locations: locations,
      discountType: discountType,
      discountAmount: discountAmount,
      offerToAllSchools: offerToAllSchools,
      selectedSchools: selectedSchools,
      startDate: startDate,
      endDate: endDate,
      isOngoing: isOngoing,
      website: website,
      facebook: facebook,
      instagram: instagram,
      tiktok: tiktok,
      x: x,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude,
      longitude: longitude,
      businessImageUrl: photoUrl,
    );
  }

  Future<Map<String, dynamic>?> getLatestRegistrationRecord() async {
    final businessId = await _resolveCurrentUserBusinessId();
    if (businessId == null) return null;

    final business =
        await _supabase
            .from('business_names')
            .select()
            .eq('uid', businessId)
            .maybeSingle();

    if (business == null) return null;

    final addresses = await _supabase
        .from('business_addresses')
        .select(
          'full_address, city_municipality, province, latitude, longitude',
        )
        .eq('uid', businessId)
        .order('location_uid', ascending: true);

    final discountInfo = _parseDiscount(business['discount'] as String?);
    final selectedSchoolsRaw = (business['group_name'] ?? '').toString().trim();
    final selectedSchools =
        selectedSchoolsRaw.isEmpty || selectedSchoolsRaw == 'All Schools'
            ? <String>[]
            : selectedSchoolsRaw
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

    final firstAddress =
        addresses.isNotEmpty ? addresses.first : <String, dynamic>{};
    final parsedValidity = _parseValidityDate(business['validity']?.toString());

    return {
      'business_name': business['company_name'],
      'locations':
          addresses
              .map((item) => (item['full_address'] ?? '').toString())
              .where((item) => item.isNotEmpty)
              .toList(),
      'discount_type': discountInfo.$1,
      'discount_amount': discountInfo.$2,
      'offer_to_all_schools':
          selectedSchoolsRaw == 'All Schools' || selectedSchools.isEmpty,
      'selected_schools': selectedSchools,
      'start_date': parsedValidity?.toIso8601String(),
      'end_date': null,
      'is_ongoing': false,
      'website': business['website'],
      'facebook': business['facebook'],
      'instagram': business['instagram'],
      'tiktok': business['tiktok'],
      'x': business['x'],
      'category_code': business['category_code'],
      'category': business['category'],
      'city_municipality': firstAddress['city_municipality'],
      'province': firstAddress['province'],
      'latitude': firstAddress['latitude'],
      'longitude': firstAddress['longitude'],
      'submission_status':
          business['is_featured'] == true ? 'approved' : 'pending',
      'created_at': null,
    };
  }

  Future<BusinessDetailsModel?> getBusinessDetailsByUid(int uid) async {
    final data =
        await _supabase
            .from('business_names')
            .select()
            .eq('uid', uid)
            .maybeSingle();

    if (data == null) return null;
    return BusinessDetailsModel.fromJson(data);
  }

  Future<List<BusinessBranchModel>> getBusinessBranchesByUid(int uid) async {
    final rows = await _supabase
        .from('business_addresses')
        .select()
        .eq('uid', uid)
        .order('location_uid', ascending: true);

    return rows.map<BusinessBranchModel>((row) {
      return BusinessBranchModel.fromJson(row);
    }).toList();
  }

  Future<BusinessModel?> getCurrentUserBusinessModel() async {
    final uid = await _resolveCurrentUserBusinessId();
    if (uid == null) return null;

    final details = await getBusinessDetailsByUid(uid);
    if (details == null) return null;

    final branches = await getBusinessBranchesByUid(uid);
    return BusinessModel.merge(base: details, branches: branches);
  }

  Future<DashboardBusinessInfo?> getBusinessInfo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await getLatestRegistrationRecord();

    if (response == null) return null;

    return DashboardBusinessInfo(
      businessName: response['business_name'] ?? '',
      category:
          BusinessCategory.normalizeKey(response['category']) ?? 'SERVICES',
      contactPerson: user.email ?? '',
      businessAddress: (response['locations'] as List).join(', '),
      businessEmail: user.email ?? '',
      submissionStatus: response['submission_status'] ?? 'pending',
    );
  }

  Future<void> updateBusinessProfileFromDashboard({
    required String businessName,
    required String businessAddress,
    required String category,
    String? discountPercentage,
  }) async {
    final businessId = await _resolveCurrentUserBusinessId();
    if (businessId == null) {
      throw Exception('Business record not found for current user.');
    }

    final normalizedCategory = BusinessCategory.normalizeKey(category);
    final categoryCode = BusinessCategory.codeForKey(normalizedCategory);
    final normalizedDiscount = discountPercentage?.trim();

    final updates = <String, dynamic>{
      'company_name': businessName,
      'category': normalizedCategory ?? 'SERVICES',
      'category_code': categoryCode,
    };

    if (normalizedDiscount != null && normalizedDiscount.isNotEmpty) {
      updates['discount'] = '$normalizedDiscount%';
    }

    await _supabase
        .from('business_names')
        .update(updates)
        .eq('uid', businessId);

    final firstAddress =
        await _supabase
            .from('business_addresses')
            .select('location_uid')
            .eq('uid', businessId)
            .order('location_uid', ascending: true)
            .limit(1)
            .maybeSingle();

    if (firstAddress == null) {
      await _supabase.from('business_addresses').insert({
        'location_uid': _generateLocationUid(businessId, 1),
        'uid': businessId,
        'company_name': businessName,
        'full_address': businessAddress,
      });
    } else {
      final locationUid = firstAddress['location_uid'];
      await _supabase
          .from('business_addresses')
          .update({
            'company_name': businessName,
            'full_address': businessAddress,
          })
          .eq('uid', businessId)
          .eq('location_uid', locationUid);
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved ✓';
      case 'rejected':
        return 'Rejected ✗';
      case 'pending':
      default:
        return 'Pending Review';
    }
  }

  /// Register a new business through Edge Function
  /// This creates entries in business_names, business_addresses, and business_accounts
  Future<void> registerBusiness({
    required String authUserId,
    required int uid,
    required String companyName,
    String? categoryCode,
    String? category,
    String? website,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? x,
    String? groupName,
    String? validity,
    String? businessImage,
    // address fields
    required int locationUid,
    required String fullAddress,
    required String cityMunicipality,
    required String province,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _supabase.auth.refreshSession();
      final session = _supabase.auth.currentSession;
      if (session == null || session.accessToken.isEmpty) {
        throw Exception('Authentication session expired. Please log in again.');
      }

      final response = await _supabase.functions.invoke(
        'register-business',
        body: {
          'authUserId': authUserId,
          'uid': uid,
          'companyName': companyName,
          'categoryCode': categoryCode,
          'category': category,
          'website': website,
          'facebook': facebook,
          'instagram': instagram,
          'tiktok': tiktok,
          'x': x,
          'groupName': groupName,
          'validity': validity,
          'businessImage': businessImage,
          'locationUid': locationUid,
          'fullAddress': fullAddress,
          'cityMunicipality': cityMunicipality,
          'province': province,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        if (data is Map && data['error'] != null) {
          throw Exception(data['error'].toString());
        }
        throw Exception('Server rejected the request (${response.status}).');
      }

      if (response.data is! Map) {
        throw Exception('Invalid response from server.');
      }

      final result = response.data as Map;
      if (result['success'] != true) {
        throw Exception(result['error'] ?? 'Failed to register business');
      }

      // Save business UID to user metadata for quick access
      await _saveCurrentUserBusinessId(uid);
    } catch (e) {
      throw Exception('Business registration failed: ${e.toString()}');
    }
  }
}
