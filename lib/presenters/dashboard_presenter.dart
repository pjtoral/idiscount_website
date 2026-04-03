class DashboardPresenter {
  static String formatDiscountSummary(
    Map<String, dynamic>? registrationRecord,
  ) {
    final amount = registrationRecord?['discount_amount'];
    final type = (registrationRecord?['discount_type'] ?? '').toString();

    if (amount == null) return 'N/A';

    final formattedAmount = amount.toString();
    if (type == 'percentage') {
      return '$formattedAmount%';
    }
    if (type == 'fixed') {
      return '₱$formattedAmount';
    }
    return '$formattedAmount ${type.isEmpty ? '' : type}';
  }

  static String formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final raw = value.toString();
    if (raw.isEmpty) return 'N/A';
    return raw.split('T').first;
  }

  static String readValue(dynamic value) {
    if (value == null) return 'N/A';
    final text = value.toString().trim();
    return text.isEmpty ? 'N/A' : text;
  }

  static List<String> asStringList(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static String socialChannelsSummary(
    Map<String, dynamic>? registrationRecord,
  ) {
    final channels = <String>[];
    if (readValue(registrationRecord?['website']) != 'N/A') {
      channels.add('Website');
    }
    if (readValue(registrationRecord?['facebook']) != 'N/A') {
      channels.add('Facebook');
    }
    if (readValue(registrationRecord?['instagram']) != 'N/A') {
      channels.add('Instagram');
    }
    if (readValue(registrationRecord?['tiktok']) != 'N/A') {
      channels.add('TikTok');
    }
    if (readValue(registrationRecord?['x']) != 'N/A') {
      channels.add('X');
    }

    return channels.isEmpty ? 'No social channels added' : channels.join(' • ');
  }

  static String submissionStatusMessage(String submissionStatus) {
    if (submissionStatus == 'pending') {
      return 'Your business is under review. We will notify you once approved.';
    }
    if (submissionStatus == 'approved') {
      return 'Your business has been approved! You can now offer discounts.';
    }
    return 'Your submission was rejected. Please contact support.';
  }
}
