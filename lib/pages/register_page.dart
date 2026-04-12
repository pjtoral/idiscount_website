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
import 'package:image/image.dart' as img;
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
        });
      }
    } catch (e) {}
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
                : '',
        province:
            _provinceController.text.isNotEmpty
                ? _provinceController.text.trim()
                : '',
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
                                      RegisterLocationsField(
                                        locationController: _locationController,
                                        locations: _locations,
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            setState(() {
                                              _locations.add(value.trim());
                                              _locationController.clear();
                                            });
                                          }
                                        },
                                        onAdd: () {
                                          final address =
                                              _locationController.text.trim();
                                          if (address.isNotEmpty) {
                                            setState(() {
                                              _locations.add(address);
                                              _locationController.clear();
                                            });
                                          }
                                        },
                                        onRemove: (index) {
                                          setState(
                                            () => _locations.removeAt(index),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      RegisterCityProvinceFields(
                                        cityMunicipalityController:
                                            _cityMunicipalityController,
                                        provinceController: _provinceController,
                                      ),
                                      const SizedBox(height: 20),
                                      RegisterCoordinatesFields(
                                        latitudeController: _latitudeController,
                                        longitudeController:
                                            _longitudeController,
                                      ),
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
                                          setState(
                                            () => _isOngoing = value ?? false,
                                          );
                                        },
                                        onTapStartDate: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            setState(() => _startDate = date);
                                          }
                                        },
                                        onTapEndDate: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                _startDate ?? DateTime.now(),
                                            firstDate:
                                                _startDate ?? DateTime.now(),
                                            lastDate: DateTime(2100),
                                          );
                                          if (date != null) {
                                            setState(() => _endDate = date);
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
