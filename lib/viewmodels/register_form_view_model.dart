class RegisterFormViewModel {
  String? validateBeforeSubmit({
    required bool formValid,
    required List<String> locations,
    required bool offerToAllSchools,
    required List<String> selectedSchools,
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
    if (!offerToAllSchools && selectedSchools.isEmpty) {
      return 'Please select at least one school';
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
