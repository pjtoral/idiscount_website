import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterFormViewModel {
  static const int minAutocompletChars = 3;
  static const int maxAddressSuggestions = 6;
  static const String _nominatimContact = 'support@idiscount.ph';

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

  // Location validation methods
  bool isValidLatitude(double? value) =>
      value != null && value >= -90 && value <= 90;

  bool isValidLongitude(double? value) =>
      value != null && value >= -180 && value <= 180;

  // Address autocomplete via Nominatim
  Future<List<AddressSuggestion>> fetchAddressSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < minAutocompletChars) {
      return [];
    }

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&addressdetails=1&limit=$maxAddressSuggestions&email=$_nominatimContact&q=${Uri.encodeQueryComponent(trimmed)}',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Autocomplete request failed (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Invalid address response.');
      }

      final suggestions =
          decoded
              .whereType<Map>()
              .map(
                (item) => AddressSuggestion(
                  address: (item['display_name'] ?? '').toString(),
                  latitude:
                      double.tryParse((item['lat'] ?? '').toString()) ?? 0.0,
                  longitude:
                      double.tryParse((item['lon'] ?? '').toString()) ?? 0.0,
                ),
              )
              .where((item) => item.address.isNotEmpty)
              .toList();

      return suggestions;
    } catch (e) {
      throw Exception('Could not load address suggestions: $e');
    }
  }

  // Location entry management
  LocationEntry createLocationEntry({
    required String address,
    String? cityMunicipality,
    String? province,
    required double? latitude,
    required double? longitude,
    required bool isPrimary,
  }) {
    return LocationEntry(
      address: address,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude,
      longitude: longitude,
      isPrimary: isPrimary,
    );
  }

  void setPrimaryLocation(List<LocationEntry> entries, int index) {
    for (var i = 0; i < entries.length; i++) {
      entries[i].isPrimary = i == index;
    }
  }

  void removeLocationAt(
    List<LocationEntry> entries,
    int index, {
    required int currentPrimaryIndex,
  }) {
    entries.removeAt(index);
    // Re-index primary if needed
    if (currentPrimaryIndex == index && entries.isNotEmpty) {
      entries[0].isPrimary = true;
    } else if (currentPrimaryIndex > index) {
      for (var i = 0; i < entries.length; i++) {
        entries[i].isPrimary = false;
      }
      if (currentPrimaryIndex - 1 >= 0 &&
          currentPrimaryIndex - 1 < entries.length) {
        entries[currentPrimaryIndex - 1].isPrimary = true;
      }
    }
  }

  LocationEntry? getPrimaryLocation(List<LocationEntry> entries) {
    try {
      return entries.firstWhere((e) => e.isPrimary);
    } catch (_) {
      return null;
    }
  }

  List<String> entriesToAddressList(List<LocationEntry> entries) {
    return entries.map((e) => e.address).toList();
  }
}

class AddressSuggestion {
  final String address;
  final double latitude;
  final double longitude;

  const AddressSuggestion({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationEntry {
  final String address;
  String? cityMunicipality;
  String? province;
  bool isPrimary;
  double? latitude;
  double? longitude;

  LocationEntry({
    required this.address,
    this.cityMunicipality,
    this.province,
    this.isPrimary = false,
    this.latitude,
    this.longitude,
  });
}
