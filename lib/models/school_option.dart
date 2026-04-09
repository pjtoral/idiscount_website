class SchoolOption {
  final String names;
  final String shortName;

  const SchoolOption({required this.names, required this.shortName});

  factory SchoolOption.fromMap(Map<String, dynamic> map) {
    final resolvedName = (map['name']).toString().trim();
    final resolvedShortName = (map['short_name']).toString().trim();

    return SchoolOption(names: resolvedName, shortName: resolvedShortName);
  }

  String get displayLabel {
    if (shortName.isEmpty) {
      return names;
    }
    return '$names ($shortName)';
  }
}
