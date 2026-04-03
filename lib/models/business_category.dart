class BusinessCategory {
  final String key;
  final String code;

  const BusinessCategory({required this.key, required this.code});

  static const List<BusinessCategory> all = [
    BusinessCategory(key: 'HEALTH', code: '100'),
    BusinessCategory(key: 'HOTELS_AND_ACCOMMODATION', code: '101'),
    BusinessCategory(key: 'SELF_CARE', code: '102'),
    BusinessCategory(key: 'CLOTHING', code: '103'),
    BusinessCategory(key: 'TECHNOLOGY', code: '104'),
    BusinessCategory(key: 'CO_WORKING_SPACES', code: '105'),
    BusinessCategory(key: 'CAFE', code: '106'),
    BusinessCategory(key: 'LIFESTYLE', code: '107'),
    BusinessCategory(key: 'FOOD', code: '108'),
    BusinessCategory(key: 'SERVICES', code: '109'),
  ];

  static List<String> get keys => all.map((item) => item.key).toList();

  static String? normalizeKey(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    final normalized = raw
        .toUpperCase()
        .replaceAll('&', 'AND')
        .replaceAll(' ', '_');

    return keys.contains(normalized) ? normalized : null;
  }

  static String? codeForKey(String? key) {
    if (key == null || key.isEmpty) return null;
    final match = all.where((item) => item.key == key).toList();
    return match.isEmpty ? null : match.first.code;
  }

  static String displayLabel(String key) {
    final words = key.toLowerCase().split('_');
    return words
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
