import 'package:flutter/foundation.dart';
import 'package:idiscount_website/models/business_profile_edit_data.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/services/app_error_service.dart';
import 'package:idiscount_website/services/business_service.dart';

enum DashboardLoadState { loaded, needsRegistration, error }

class DashboardViewModel extends ChangeNotifier {
  final BusinessService _businessService;

  DashboardBusinessInfo? businessInfo;
  Map<String, dynamic>? registrationRecord;
  bool isLoading = true;
  String? errorMessage;

  DashboardViewModel({BusinessService? businessService})
    : _businessService = businessService ?? BusinessService();

  Future<DashboardLoadState> loadDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final hasCompleted = await _businessService.hasCompletedRegistration();
      if (!hasCompleted) {
        isLoading = false;
        notifyListeners();
        return DashboardLoadState.needsRegistration;
      }

      final loadedInfo = await _businessService.getBusinessInfo();
      final loadedRecord = await _businessService.getLatestRegistrationRecord();

      if (loadedInfo == null || loadedRecord == null) {
        isLoading = false;
        notifyListeners();
        return DashboardLoadState.needsRegistration;
      }

      businessInfo = loadedInfo;
      registrationRecord = loadedRecord;
      isLoading = false;
      notifyListeners();
      return DashboardLoadState.loaded;
    } catch (e) {
      errorMessage = AppErrorService.toMessage(
        e,
        fallback: 'Error loading dashboard. Please try again.',
      );
      isLoading = false;
      notifyListeners();
      return DashboardLoadState.error;
    }
  }

  Future<void> reloadDashboardData() async {
    final loadedInfo = await _businessService.getBusinessInfo();
    final loadedRecord = await _businessService.getLatestRegistrationRecord();

    if (loadedInfo == null || loadedRecord == null) {
      throw Exception('Unable to reload updated business data.');
    }

    businessInfo = loadedInfo;
    registrationRecord = loadedRecord;
    notifyListeners();
  }

  Future<void> saveProfileEdits(BusinessProfileEditData updatedInfo) async {
    await _businessService.updateBusinessProfileFromDashboard(
      businessName: updatedInfo.businessName,
      businessAddress: updatedInfo.businessAddress,
      category: updatedInfo.category,
      discountPercentage: updatedInfo.discountPercentage,
    );
    await reloadDashboardData();
  }

  String? extractPercentageDiscount() {
    final type = (registrationRecord?['discount_type'] ?? '').toString();
    if (type != 'percentage') return null;

    final amount = registrationRecord?['discount_amount'];
    if (amount == null) return null;
    return amount.toString();
  }
}
