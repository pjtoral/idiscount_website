class RegisterFormViewModel {
  double computeProgress({
    required String businessName,
    required List<String> locations,
    required String? discountType,
    required String discountAmount,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool isOngoing,
  }) {
    int filledFields = 0;
    const int totalFields = 7;

    if (businessName.trim().isNotEmpty) filledFields++;
    if (locations.isNotEmpty) filledFields++;
    if (discountType != null) filledFields++;
    if (discountAmount.trim().isNotEmpty) filledFields++;
    if (startDate != null) filledFields++;
    if (isOngoing || endDate != null) filledFields++;

    return filledFields / totalFields;
  }

  String? validateBeforeSubmit({
    required bool formValid,
    required List<String> locations,
    required String? selectedCategory,
    required String? selectedPhotoFileName,
    required Object? selectedPhotoData,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool isOngoing,
  }) {
    if (!formValid) {
      return 'Please complete all required fields';
    }
    if (locations.isEmpty) {
      return 'Please add at least one location';
    }
    if (selectedCategory == null) {
      return 'Please select a business category';
    }
    if (selectedPhotoData == null || selectedPhotoFileName == null) {
      return 'Please upload a photo';
    }
    if (startDate == null) {
      return 'Please select a start date';
    }
    if (!isOngoing && endDate == null) {
      return 'Please select an end date or mark as ongoing';
    }
    return null;
  }

  String buildValidityString({
    required DateTime startDate,
    required DateTime? endDate,
    required bool isOngoing,
  }) {
    final validityDate = isOngoing || endDate == null ? startDate : endDate;
    return '${validityDate.day.toString().padLeft(2, '0')}/'
        '${validityDate.month.toString().padLeft(2, '0')}/'
        '${validityDate.year}';
  }
}
