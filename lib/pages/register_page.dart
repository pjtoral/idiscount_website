import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/models/business_category.dart';
import 'package:idiscount_website/models/school_option.dart';
import 'package:idiscount_website/pages/widgets/register_sections.dart';
import 'package:idiscount_website/services/app_error_service.dart';
import 'package:idiscount_website/services/auth_service.dart';
import 'package:idiscount_website/services/business_service.dart';
import 'package:idiscount_website/services/school_service.dart';
import 'package:idiscount_website/viewmodels/register_form_view_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';
import 'dart:ui';
import 'dart:html' as html;
import 'dart:typed_data';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _businessService = BusinessService();
  final _schoolService = SchoolService();
  final _formViewModel = RegisterFormViewModel();

  final _businessNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _xController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _cityMunicipalityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedDiscountType = 'percentage';
  bool _offerToAllSchools = true;
  bool _isOngoing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _locations = [];
  final List<LocationEntry> _locationEntries = [];
  List<AddressSuggestion> _addressSuggestions = [];
  bool _isSearchingAddresses = false;
  bool _isAddingLocation = false;
  int _primaryLocationIndex = -1;
  List<String> _selectedSchools = [];
  List<SchoolOption> _schools = [];
  bool _isLoadingSchools = true;
  String? _schoolLoadError;
  String? _selectedPhotoFileName;
  Uint8List? _selectedPhotoData;
  bool _isPhotoProcessing = false;
  double _photoProcessingProgress = 0.0;
  bool _isPhotoUploading = false;
  double _photoUploadProgress = 0.0;
  String? _selectedCategory;
  static const LatLng _defaultMapCenter = LatLng(14.5995, 120.9842);

  List<String> get _allSchoolNames => _schools.map((s) => s.names).toList();

  void _syncOfferToAllFromSelection() {
    if (_schools.isEmpty) {
      _offerToAllSchools = false;
      return;
    }

    final allSelected = _allSchoolNames.every(_selectedSchools.contains);
    _offerToAllSchools = allSelected;
  }

  void _applyOfferToAllSelection(bool isChecked) {
    _offerToAllSchools = isChecked;
    if (isChecked) {
      _selectedSchools = _allSchoolNames;
    } else {
      _selectedSchools = [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _initPage();
  }

  Future<void> _loadSchools() async {
    try {
      final schools = await _schoolService.fetchSchools();
      if (!mounted) return;

      setState(() {
        _schools = schools;
        _selectedSchools =
            _selectedSchools
                .where((selected) => _allSchoolNames.contains(selected))
                .toList();
        if (_offerToAllSchools) {
          _selectedSchools = _allSchoolNames;
        }
        _syncOfferToAllFromSelection();
        _schoolLoadError = null;
        _isLoadingSchools = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _schoolLoadError = AppErrorService.toMessage(
          e,
          fallback: 'Failed to load schools.',
        );
        _isLoadingSchools = false;
      });
    }
  }

  Future<void> _initPage() async {
    final isVerified = await _authService.refreshAndCheckEmailVerified();
    if (!mounted) return;

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before registration.'),
          backgroundColor: Colors.orange,
        ),
      );
      context.go('/email-verification');
      return;
    }

    await _loadDraft();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _xController.dispose();
    _discountAmountController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _cityMunicipalityController.dispose();
    _provinceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await _businessService.loadDraft();
      if (draft != null && mounted) {
        setState(() {
          _businessNameController.text = draft['business_name'] ?? '';
          _selectedCategory = BusinessCategory.normalizeKey(draft['category']);
          _locations = List<String>.from(draft['locations'] ?? []);
          _locationEntries
            ..clear()
            ..addAll(
              _locations.map((address) => LocationEntry(address: address)),
            );
          if (_locationEntries.isNotEmpty) {
            _primaryLocationIndex = 0;
            _locationEntries[0].isPrimary = true;
            _locationEntries[0].cityMunicipality =
                draft['city_municipality']?.toString();
            _locationEntries[0].province = draft['province']?.toString();
          }
          _selectedDiscountType = draft['discount_type'];
          _discountAmountController.text =
              draft['discount_amount']?.toString() ?? '';
          _offerToAllSchools = draft['offer_to_all_schools'] ?? true;
          _selectedSchools = List<String>.from(draft['selected_schools'] ?? []);
          if (draft['start_date'] != null) {
            _startDate = DateTime.parse(draft['start_date']);
          }
          if (draft['end_date'] != null) {
            _endDate = DateTime.parse(draft['end_date']);
          }
          _isOngoing = draft['is_ongoing'] ?? false;
          _websiteController.text = draft['website'] ?? '';
          _facebookController.text = draft['facebook'] ?? '';
          _instagramController.text = draft['instagram'] ?? '';
          _tiktokController.text = draft['tiktok'] ?? '';
          _xController.text = draft['x'] ?? '';
          _cityMunicipalityController.text = draft['city_municipality'] ?? '';
          _provinceController.text = draft['province'] ?? '';
          _latitudeController.text = draft['latitude']?.toString() ?? '';
          _longitudeController.text = draft['longitude']?.toString() ?? '';
          if (_locationEntries.isNotEmpty) {
            final lat = double.tryParse(_latitudeController.text);
            final lng = double.tryParse(_longitudeController.text);
            if (lat != null && lng != null) {
              _locationEntries[0].latitude = lat;
              _locationEntries[0].longitude = lng;
            }
          }
        });
      }
    } catch (e) {}
  }

  Future<void> _searchAddressSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      if (!mounted) return;
      setState(() {
        _addressSuggestions = [];
        _isSearchingAddresses = false;
      });
      return;
    }

    setState(() {
      _isSearchingAddresses = true;
    });

    try {
      final suggestions = await _formViewModel.fetchAddressSuggestions(trimmed);
      if (!mounted) return;
      setState(() {
        _addressSuggestions = suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _addressSuggestions = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorService.toMessage(
              e,
              fallback: 'Unable to load place suggestions right now.',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingAddresses = false;
        });
      }
    }
  }

  void _selectAddressSuggestion(AddressSuggestion suggestion) {
    setState(() {
      _locationController.text = suggestion.address;
      _latitudeController.text = suggestion.latitude.toStringAsFixed(6);
      _longitudeController.text = suggestion.longitude.toStringAsFixed(6);
      _addressSuggestions = [];
    });
  }

  void _syncLocationsList() {
    _locations = _locationEntries.map((entry) => entry.address).toList();
  }

  List<Map<String, dynamic>> _buildLocationDetailsPayload() {
    return _locationEntries
        .map(
          (entry) => {
            'full_address': entry.address,
            'city_municipality': entry.cityMunicipality,
            'province': entry.province,
            'latitude': entry.latitude,
            'longitude': entry.longitude,
          },
        )
        .toList();
  }

  void _startAddingLocation() {
    setState(() {
      _isAddingLocation = true;
      _locationController.clear();
      _cityMunicipalityController.clear();
      _provinceController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _addressSuggestions = [];
    });
  }

  void _cancelAddingLocation() {
    setState(() {
      _isAddingLocation = false;
      _locationController.clear();
      _cityMunicipalityController.clear();
      _provinceController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _addressSuggestions = [];
    });
  }

  void _addLocation() {
    final address = _locationController.text.trim();
    final cityMunicipality = _cityMunicipalityController.text.trim();
    final province = _provinceController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter an address first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cityMunicipality.isEmpty || province.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter municipality and province.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    if (!_formViewModel.isValidLatitude(lat) ||
        !_formViewModel.isValidLongitude(lng)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide valid latitude and longitude.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      final entry = _formViewModel.createLocationEntry(
        address: address,
        cityMunicipality: cityMunicipality,
        province: province,
        latitude: lat,
        longitude: lng,
        isPrimary: _locationEntries.isEmpty,
      );
      _locationEntries.add(entry);

      if (_locationEntries.length == 1) {
        _primaryLocationIndex = 0;
      }

      _syncLocationsList();
      _locationController.clear();
      _cityMunicipalityController.clear();
      _provinceController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _isAddingLocation = false;
      _addressSuggestions = [];
    });
  }

  void _setPrimaryLocation(int index) {
    setState(() {
      _formViewModel.setPrimaryLocation(_locationEntries, index);
      _primaryLocationIndex = index;

      final primary = _locationEntries[index];
      _cityMunicipalityController.text = primary.cityMunicipality ?? '';
      _provinceController.text = primary.province ?? '';
      if (primary.latitude != null && primary.longitude != null) {
        _latitudeController.text = primary.latitude!.toStringAsFixed(6);
        _longitudeController.text = primary.longitude!.toStringAsFixed(6);
      }
    });
  }

  void _removeLocationAt(int index) {
    setState(() {
      _formViewModel.removeLocationAt(
        _locationEntries,
        index,
        currentPrimaryIndex: _primaryLocationIndex,
      );

      if (_locationEntries.isEmpty) {
        _primaryLocationIndex = -1;
      } else {
        if (_primaryLocationIndex == index) {
          _primaryLocationIndex = 0;
        } else if (_primaryLocationIndex > index) {
          _primaryLocationIndex -= 1;
        }

        final primary = _locationEntries[_primaryLocationIndex];
        _cityMunicipalityController.text = primary.cityMunicipality ?? '';
        _provinceController.text = primary.province ?? '';
        if (primary.latitude != null && primary.longitude != null) {
          _latitudeController.text = primary.latitude!.toStringAsFixed(6);
          _longitudeController.text = primary.longitude!.toStringAsFixed(6);
        }
      }

      _syncLocationsList();
    });
  }

  void _updateCoordinatesFromMap(LatLng point) {
    setState(() {
      _latitudeController.text = point.latitude.toStringAsFixed(6);
      _longitudeController.text = point.longitude.toStringAsFixed(6);

      if (!_isAddingLocation &&
          _primaryLocationIndex >= 0 &&
          _primaryLocationIndex < _locationEntries.length) {
        _locationEntries[_primaryLocationIndex].latitude = point.latitude;
        _locationEntries[_primaryLocationIndex].longitude = point.longitude;
      }
    });
  }

  Widget _buildLocationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location/s *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (!_isAddingLocation)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _startAddingLocation,
              icon: const Icon(Icons.add),
              label: const Text('Add location'),
            ),
          ),
        if (_isAddingLocation) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Full Address *',
                    hintText: 'Search address...',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _searchAddressSuggestions,
                ),
                if (_isSearchingAddresses) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (_addressSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _addressSuggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _addressSuggestions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            item.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectAddressSuggestion(item),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityMunicipalityController,
                        decoration: InputDecoration(
                          labelText: 'Municipality/City *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _provinceController,
                        decoration: InputDecoration(
                          labelText: 'Province *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCoordinatesAndMapSection(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancelAddingLocation,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addLocation,
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (_locationEntries.isEmpty)
          Text(
            'At least one location is required.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _locationEntries.length,
            itemBuilder: (context, index) {
              final location = _locationEntries[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _primaryLocationIndex,
                      onChanged: (value) {
                        if (value != null) {
                          _setPrimaryLocation(value);
                        }
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.address,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [location.cityMunicipality, location.province]
                                .where(
                                  (item) =>
                                      item != null && item.trim().isNotEmpty,
                                )
                                .join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location.isPrimary
                                ? 'Primary location'
                                : 'Set as primary',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeLocationAt(index),
                      splashRadius: 20,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCoordinatesAndMapSection() {
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    final hasValidPoint =
        _formViewModel.isValidLatitude(lat) &&
        _formViewModel.isValidLongitude(lng);
    final safeLat = hasValidPoint ? lat! : _defaultMapCenter.latitude;
    final safeLng = hasValidPoint ? lng! : _defaultMapCenter.longitude;
    final mapCenter = hasValidPoint ? LatLng(lat!, lng!) : _defaultMapCenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Latitude *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  hasValidPoint
                      ? safeLat.toStringAsFixed(6)
                      : 'Tap map to set latitude',
                  style: TextStyle(
                    color: hasValidPoint ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Longitude *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  hasValidPoint
                      ? safeLng.toStringAsFixed(6)
                      : 'Tap map to set longitude',
                  style: TextStyle(
                    color: hasValidPoint ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Map Preview (tap to place or adjust pin location)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: hasValidPoint ? 15 : 12,
                onTap: (_, point) => _updateCoordinatesFromMap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.idiscount.website',
                ),
                if (hasValidPoint)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 44,
                        height: 44,
                        point: LatLng(safeLat, safeLng),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveDraft() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final selectedCategory = _selectedCategory;
      await _businessService.saveDraft(
        businessName: _businessNameController.text.trim(),
        categoryCode: BusinessCategory.codeForKey(selectedCategory),
        category: selectedCategory,
        locations: _locations,
        locationDetails: _buildLocationDetailsPayload(),
        discountType: _selectedDiscountType ?? 'percentage',
        discountAmount:
            _discountAmountController.text.isNotEmpty
                ? double.parse(_discountAmountController.text)
                : 0.0,
        offerToAllSchools: _offerToAllSchools,
        selectedSchools: _selectedSchools,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate,
        isOngoing: _isOngoing,
        website:
            _websiteController.text.isNotEmpty
                ? _websiteController.text.trim()
                : null,
        facebook:
            _facebookController.text.isNotEmpty
                ? _facebookController.text.trim()
                : null,
        instagram:
            _instagramController.text.isNotEmpty
                ? _instagramController.text.trim()
                : null,
        tiktok:
            _tiktokController.text.isNotEmpty
                ? _tiktokController.text.trim()
                : null,
        x: _xController.text.isNotEmpty ? _xController.text.trim() : null,
        cityMunicipality:
            _cityMunicipalityController.text.isNotEmpty
                ? _cityMunicipalityController.text.trim()
                : null,
        province:
            _provinceController.text.isNotEmpty
                ? _provinceController.text.trim()
                : null,
        latitude:
            _latitudeController.text.isNotEmpty
                ? double.tryParse(_latitudeController.text)
                : null,
        longitude:
            _longitudeController.text.isNotEmpty
                ? double.tryParse(_longitudeController.text)
                : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorService.toMessage(
                e,
                fallback: 'Failed to save draft. Please try again.',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPhotoFile() async {
    try {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept =
          'image/jpeg,image/png,image/webp,.jpg,.jpeg,.png,.webp';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final fileName = file.name.toLowerCase();
          final isSupported =
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg') ||
              fileName.endsWith('.png') ||
              fileName.endsWith('.webp');

          if (!isSupported) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only JPG, PNG, and WEBP files are supported'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final fileSize = file.size ?? 0;
          if (fileSize > 5 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File size exceeds 5MB limit'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            _isPhotoProcessing = true;
            _photoProcessingProgress = 0.05;
          });

          final reader = html.FileReader();

          reader.onProgress.listen((event) {
            if (!mounted) return;
            if (event.total != null && event.total! > 0) {
              final progress = (event.loaded ?? 0) / event.total!;
              setState(() {
                _photoProcessingProgress = 0.05 + (progress * 0.45);
              });
            }
          });

          reader.onLoadEnd.listen((e) async {
            try {
              final fileData = reader.result as Uint8List?;
              if (fileData == null) {
                throw Exception('Could not read selected file.');
              }

              if (!mounted) return;
              setState(() {
                _photoProcessingProgress = 0.65;
              });

              final compressed = await _compressImageForUpload(
                fileData,
                file.type ?? '',
                file.name,
              );

              if (!mounted) return;
              setState(() {
                _photoProcessingProgress = 1.0;
                _selectedPhotoFileName = file.name;
                _selectedPhotoData = compressed;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Photo selected: ${file.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (err) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing photo: $err'),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isPhotoProcessing = false;
                  _photoProcessingProgress = 0.0;
                });
              }
            }
          });

          reader.readAsArrayBuffer(file);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Uint8List> _compressImageForUpload(
    Uint8List bytes,
    String mimeType,
    String fileName,
  ) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unsupported image format.');
    }

    var processed = decoded;
    const maxDimension = 1600;
    if (processed.width > maxDimension || processed.height > maxDimension) {
      if (processed.width >= processed.height) {
        processed = img.copyResize(processed, width: maxDimension);
      } else {
        processed = img.copyResize(processed, height: maxDimension);
      }
    }

    final lowerName = fileName.toLowerCase();
    final isPng = mimeType.contains('png') || lowerName.endsWith('.png');

    late Uint8List compressed;
    if (isPng) {
      compressed = Uint8List.fromList(img.encodePng(processed, level: 6));
    } else {
      compressed = Uint8List.fromList(img.encodeJpg(processed, quality: 82));
    }

    return compressed.length <= bytes.length ? compressed : bytes;
  }

  Future<DateTimeRange?> _showBlurredDateRangeModal() async {
    final now = DateTime.now();
    var tempStart = _startDate ?? now;
    var tempEnd = _endDate ?? tempStart.add(const Duration(days: 30));
    var selectingStart = true;

    return showGeneralDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close date range modal',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pickerDate = selectingStart ? tempStart : tempEnd;
            final firstDate = selectingStart ? now : tempStart;

            return Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Validity Date Range',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text(
                                      'Start: ${tempStart.toString().split(' ')[0]}',
                                    ),
                                    selected: selectingStart,
                                    onSelected:
                                        (_) => setModalState(
                                          () => selectingStart = true,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Text(
                                      'End: ${tempEnd.toString().split(' ')[0]}',
                                    ),
                                    selected: !selectingStart,
                                    onSelected:
                                        (_) => setModalState(
                                          () => selectingStart = false,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CalendarDatePicker(
                              initialDate:
                                  pickerDate.isBefore(firstDate)
                                      ? firstDate
                                      : pickerDate,
                              firstDate: firstDate,
                              lastDate: DateTime(2100),
                              onDateChanged: (date) {
                                setModalState(() {
                                  if (selectingStart) {
                                    tempStart = date;
                                    if (tempEnd.isBefore(tempStart)) {
                                      tempEnd = tempStart;
                                    }
                                  } else {
                                    tempEnd = date;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(
                                        DateTimeRange(
                                          start: tempStart,
                                          end: tempEnd,
                                        ),
                                      ),
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Future<void> _submitRegistration() async {
    final isVerified = await _authService.refreshAndCheckEmailVerified();
    if (!mounted) return;

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      context.go('/email-verification');
      return;
    }

    final validationMessage = _formViewModel.validateBeforeSubmit(
      formValid: _formKey.currentState!.validate(),
      locations: _locations,
      offerToAllSchools: _offerToAllSchools,
      selectedSchools: _selectedSchools,
      selectedCategory: _selectedCategory,
      selectedPhotoFileName: _selectedPhotoFileName,
      selectedPhotoData: _selectedPhotoData,
      startDate: _startDate,
      endDate: _endDate,
      isOngoing: _isOngoing,
    );

    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMessage), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    setState(() {
      _isPhotoUploading = true;
      _photoUploadProgress = 0.0;
    });

    try {
      final selectedCategory = _selectedCategory!;
      await _businessService.submitBusinessRegistration(
        businessName: _businessNameController.text.trim(),
        categoryCode: BusinessCategory.codeForKey(selectedCategory),
        category: selectedCategory,
        locations: _locations,
        locationDetails: _buildLocationDetailsPayload(),
        discountType: _selectedDiscountType ?? 'percentage',
        discountAmount: double.parse(_discountAmountController.text),
        offerToAllSchools: _offerToAllSchools,
        selectedSchools: _selectedSchools,
        startDate: _startDate!,
        endDate: _endDate,
        isOngoing: _isOngoing,
        website:
            _websiteController.text.isNotEmpty
                ? _websiteController.text.trim()
                : null,
        facebook:
            _facebookController.text.isNotEmpty
                ? _facebookController.text.trim()
                : null,
        instagram:
            _instagramController.text.isNotEmpty
                ? _instagramController.text.trim()
                : null,
        tiktok:
            _tiktokController.text.isNotEmpty
                ? _tiktokController.text.trim()
                : null,
        x: _xController.text.isNotEmpty ? _xController.text.trim() : null,
        cityMunicipality:
            _cityMunicipalityController.text.isNotEmpty
                ? _cityMunicipalityController.text.trim()
                : null,
        province:
            _provinceController.text.isNotEmpty
                ? _provinceController.text.trim()
                : null,
        latitude:
            _latitudeController.text.isNotEmpty
                ? double.tryParse(_latitudeController.text)
                : null,
        longitude:
            _longitudeController.text.isNotEmpty
                ? double.tryParse(_longitudeController.text)
                : null,
        photoFileName: _selectedPhotoFileName,
        photoData: _selectedPhotoData,
        onUploadProgress: (value) {
          if (!mounted) return;
          setState(() {
            _photoUploadProgress = value;
          });
        },
      );

      if (mounted) {
        Navigator.pop(context);

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Success!'),
                content: const Text(
                  'Your business has been registered and linked to your account. '
                  'You can now access your business dashboard.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorService.toMessage(
                e,
                fallback:
                    'Registration failed. Please check your details and try again.',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPhotoUploading = false;
          _photoUploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/idiscount_web_bg.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(190, 255, 255, 255),
                    Color.fromARGB(170, 249, 247, 210),
                    Color.fromARGB(190, 187, 207, 177),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 640,
                  maxHeight: 600,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Business Registration',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => context.go('/'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFFD54F),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const RegisterSectionHeader(
                                        title: 'Basic Business Information',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildBusinessNameField(),
                                      const SizedBox(height: 20),
                                      _buildCategoryFields(),
                                      const SizedBox(height: 20),
                                      RegisterBusinessPhotoField(
                                        selectedPhotoFileName:
                                            _selectedPhotoFileName,
                                        selectedPhotoData: _selectedPhotoData,
                                        hasPhotoData:
                                            _selectedPhotoData != null,
                                        isProcessing: _isPhotoProcessing,
                                        processingProgress:
                                            _photoProcessingProgress,
                                        isUploading: _isPhotoUploading,
                                        uploadProgress: _photoUploadProgress,
                                        onPickPhoto: _pickPhotoFile,
                                        onRemovePhoto: () {
                                          setState(() {
                                            _selectedPhotoFileName = null;
                                            _selectedPhotoData = null;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      const RegisterSectionHeader(
                                        title: 'Location Information',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildLocationsField(),
                                      const SizedBox(height: 32),

                                      const RegisterSectionHeader(
                                        title: 'Discount Details',
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RegisterDiscountAmountField(
                                              controller:
                                                  _discountAmountController,
                                              selectedDiscountType:
                                                  _selectedDiscountType,
                                              onChanged: (_) {},
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 140,
                                            child: RegisterDiscountTypeField(
                                              selectedDiscountType:
                                                  _selectedDiscountType,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedDiscountType = value;
                                                  _discountAmountController
                                                      .clear();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),

                                      const RegisterSectionHeader(
                                        title: 'Partnership Details',
                                      ),
                                      const SizedBox(height: 16),
                                      RegisterSchoolPartnershipField(
                                        offerToAllSchools: _offerToAllSchools,
                                        schools: _schools,
                                        selectedSchools: _selectedSchools,
                                        isLoadingSchools: _isLoadingSchools,
                                        loadErrorMessage: _schoolLoadError,
                                        onOfferToAllSchoolsChanged: (value) {
                                          setState(() {
                                            _applyOfferToAllSelection(
                                              value ?? false,
                                            );
                                          });
                                        },
                                        onSchoolToggled: (schoolName) {
                                          setState(() {
                                            if (_selectedSchools.contains(
                                              schoolName,
                                            )) {
                                              _selectedSchools.remove(
                                                schoolName,
                                              );
                                            } else {
                                              _selectedSchools.add(schoolName);
                                            }
                                            _syncOfferToAllFromSelection();
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      const RegisterSectionHeader(
                                        title: 'Social Media & Online Presence',
                                      ),
                                      const SizedBox(height: 16),
                                      RegisterSocialMediaFields(
                                        websiteController: _websiteController,
                                        facebookController: _facebookController,
                                        instagramController:
                                            _instagramController,
                                        tiktokController: _tiktokController,
                                        xController: _xController,
                                      ),
                                      const SizedBox(height: 32),

                                      const RegisterSectionHeader(
                                        title: 'Validity Period',
                                      ),
                                      const SizedBox(height: 16),
                                      RegisterValidityField(
                                        isOngoing: _isOngoing,
                                        startDate: _startDate,
                                        endDate: _endDate,
                                        onToggleOngoing: (value) {
                                          setState(() {
                                            _isOngoing = value ?? false;
                                            if (_isOngoing) {
                                              _endDate = null;
                                              _startDate ??= DateTime.now();
                                            }
                                          });
                                        },
                                        onTapDateRange: () async {
                                          final picked =
                                              await _showBlurredDateRangeModal();

                                          if (picked != null) {
                                            setState(() {
                                              _startDate = picked.start;
                                              _endDate = picked.end;
                                              _isOngoing = false;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 40),

                                      RegisterFormActions(
                                        onSaveDraft: _saveDraft,
                                        onSubmit: _submitRegistration,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNameField() {
    return TextFormField(
      controller: _businessNameController,
      decoration: InputDecoration(
        labelText: 'Business Name *',
        hintText: 'Enter your business name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        helperText: '3-100 characters',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Business name is required';
        }
        if (value.length < 3 || value.length > 100) {
          return 'Business name must be 3-100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryFields() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          BusinessCategory.keys
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(BusinessCategory.displayLabel(category)),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }
}
