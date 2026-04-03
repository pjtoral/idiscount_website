class BusinessInfo {
  final String businessName;
  final String businessType;
  final String contactPerson;
  final String contactNumber;
  final String businessAddress;
  final String businessEmail;
  final String submissionStatus; // pending, approved, rejected

  BusinessInfo({
    required this.businessName,
    required this.businessType,
    required this.contactPerson,
    required this.contactNumber,
    required this.businessAddress,
    required this.businessEmail,
    required this.submissionStatus,
  });

  BusinessInfo copyWith({
    String? businessName,
    String? businessType,
    String? contactPerson,
    String? contactNumber,
    String? businessAddress,
    String? businessEmail,
    String? submissionStatus,
  }) {
    return BusinessInfo(
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      businessAddress: businessAddress ?? this.businessAddress,
      businessEmail: businessEmail ?? this.businessEmail,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}
