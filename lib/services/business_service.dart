import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_info.dart';
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

  Future<void> saveDraft({
    required String businessName,
    required List<String> locations,
    required String discountType,
    required double discountAmount,
    required String discountFrequency,
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
    double? latitude,
    double? longitude,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final data = {
      'user_id': user.id,
      'business_name': businessName,
      'locations': locations,
      'discount_type': discountType,
      'discount_amount': discountAmount,
      'discount_frequency': discountFrequency,
      'offer_to_all_schools': offerToAllSchools,
      'selected_schools': selectedSchools,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_ongoing': isOngoing,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'x': x,
      'latitude': latitude,
      'longitude': longitude,
      'submission_status': 'draft',
      'created_at': DateTime.now().toIso8601String(),
    };

    final existing =
        await _supabase
            .from('business_registrations')
            .select('id')
            .eq('user_id', user.id)
            .eq('submission_status', 'draft')
            .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('business_registrations')
          .update(data)
          .eq('id', existing['id']);
    } else {
      await _supabase.from('business_registrations').insert(data);
    }
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await _supabase
        .from('business_registrations')
        .select()
        .eq('user_id', user.id)
        .eq('submission_status', 'draft')
        .maybeSingle();
  }

  Future<bool> hasCompletedRegistration() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final result =
        await _supabase
            .from('business_registrations')
            .select('submission_status')
            .eq('user_id', user.id)
            .inFilter('submission_status', ['pending', 'approved'])
            .maybeSingle();

    return result != null;
  }

  Future<void> submitBusinessRegistration({
    required String businessName,
    required List<String> locations,
    required String discountType,
    required double discountAmount,
    required String discountFrequency,
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

    final data = {
      'user_id': user.id,
      'business_name': businessName,
      'locations': locations,
      'discount_type': discountType,
      'discount_amount': discountAmount,
      'discount_frequency': discountFrequency,
      'offer_to_all_schools': offerToAllSchools,
      'selected_schools': selectedSchools,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_ongoing': isOngoing,
      'website': website,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'x': x,
      'latitude': latitude,
      'longitude': longitude,
      'submission_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    // Insert into Supabase
    await _supabase.from('business_registrations').insert(data);
  }

  Future<Map<String, dynamic>?> getLatestRegistrationRecord() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return await _supabase
        .from('business_registrations')
        .select()
        .eq('user_id', user.id)
        .inFilter('submission_status', ['pending', 'approved', 'rejected'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<BusinessInfo?> getBusinessInfo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await getLatestRegistrationRecord();

    if (response == null) return null;

    return BusinessInfo(
      businessName: response['business_name'] ?? '',
      businessType: 'Business',
      contactPerson: user.email ?? '',
      contactNumber: '',
      businessAddress: (response['locations'] as List).join(', '),
      businessEmail: user.email ?? '',
      submissionStatus: response['submission_status'] ?? 'pending',
    );
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
}
