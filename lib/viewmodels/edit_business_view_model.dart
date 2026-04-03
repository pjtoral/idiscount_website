import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_category.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/models/business_profile_edit_data.dart';

class EditBusinessViewModel extends ChangeNotifier {
  final TextEditingController businessNameController;
  final TextEditingController contactPersonController;
  final TextEditingController discountPercentageController;
  final TextEditingController businessAddressController;
  final TextEditingController businessEmailController;

  String selectedCategory;
  bool isSaving = false;

  EditBusinessViewModel._({
    required this.businessNameController,
    required this.contactPersonController,
    required this.discountPercentageController,
    required this.businessAddressController,
    required this.businessEmailController,
    required this.selectedCategory,
  });

  factory EditBusinessViewModel.fromBusinessInfo(
    DashboardBusinessInfo businessInfo, {
    String? initialDiscountPercentage,
  }) {
    final initialCategory =
        BusinessCategory.normalizeKey(businessInfo.category) ?? 'SERVICES';

    return EditBusinessViewModel._(
      businessNameController: TextEditingController(
        text: businessInfo.businessName,
      ),
      contactPersonController: TextEditingController(
        text: businessInfo.contactPerson,
      ),
      discountPercentageController: TextEditingController(
        text: initialDiscountPercentage ?? '',
      ),
      businessAddressController: TextEditingController(
        text: businessInfo.businessAddress,
      ),
      businessEmailController: TextEditingController(
        text: businessInfo.businessEmail,
      ),
      selectedCategory: initialCategory,
    );
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business name is required';
    }
    return null;
  }

  String? validateContactPerson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact person is required';
    }
    return null;
  }

  String? validateDiscountPercentage(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Discount percentage is required';
    }

    final percent = double.tryParse(text);
    if (percent == null) {
      return 'Enter a valid number';
    }

    if (percent <= 0 || percent > 100) {
      return 'Discount must be between 0 and 100';
    }

    return null;
  }

  String? validateBusinessAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business address is required';
    }
    return null;
  }

  String? validateBusinessEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Business email is required';
    }
    if (!text.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  BusinessProfileEditData buildPayload() {
    return BusinessProfileEditData(
      businessName: businessNameController.text.trim(),
      category: selectedCategory,
      discountPercentage: discountPercentageController.text.trim(),
      businessAddress: businessAddressController.text.trim(),
    );
  }

  void setSaving(bool value) {
    isSaving = value;
    notifyListeners();
  }

  String formatCategoryLabel(String value) {
    return BusinessCategory.displayLabel(value);
  }

  void disposeControllers() {
    businessNameController.dispose();
    contactPersonController.dispose();
    discountPercentageController.dispose();
    businessAddressController.dispose();
    businessEmailController.dispose();
  }
}
