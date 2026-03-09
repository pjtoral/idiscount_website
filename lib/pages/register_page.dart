import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/services/auth_service.dart';
import 'package:idiscount_website/services/business_service.dart';
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
  double _progress = 0.0;

  final _businessNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _xController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedDiscountType = 'percentage';
  String? _selectedDiscountFrequency = 'everyday';
  bool _offerToAllSchools = true;
  bool _isOngoing = false;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _locations = [];
  List<String> _selectedSchools = [];
  String? _selectedPhotoFileName;
  Uint8List? _selectedPhotoData;

  @override
  void initState() {
    super.initState();
    _initPage();
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
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    try {
      final draft = await _businessService.loadDraft();
      if (draft != null && mounted) {
        setState(() {
          _businessNameController.text = draft['business_name'] ?? '';
          _locations = List<String>.from(draft['locations'] ?? []);
          _selectedDiscountType = draft['discount_type'];
          _discountAmountController.text =
              draft['discount_amount']?.toString() ?? '';
          _selectedDiscountFrequency = draft['discount_frequency'];
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
          _latitudeController.text = draft['latitude']?.toString() ?? '';
          _longitudeController.text = draft['longitude']?.toString() ?? '';
        });
        _updateProgress();
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
      await _businessService.saveDraft(
        businessName: _businessNameController.text.trim(),
        locations: _locations,
        discountType: _selectedDiscountType ?? 'percentage',
        discountAmount:
            _discountAmountController.text.isNotEmpty
                ? double.parse(_discountAmountController.text)
                : 0.0,
        discountFrequency: _selectedDiscountFrequency ?? 'everyday',
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
            content: Text('Failed to save draft: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateProgress() {
    int filledFields = 0;
    int totalFields = 7;

    if (_businessNameController.text.isNotEmpty) filledFields++;
    if (_locations.isNotEmpty) filledFields++;
    if (_selectedDiscountType != null) filledFields++;
    if (_discountAmountController.text.isNotEmpty) filledFields++;
    if (_selectedDiscountFrequency != null) filledFields++;
    if (_startDate != null) filledFields++;
    if (_isOngoing || _endDate != null) filledFields++;

    setState(() {
      _progress = filledFields / totalFields;
    });
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
          final reader = html.FileReader();

          reader.onLoadEnd.listen((e) {
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

            final fileData = reader.result as Uint8List?;
            if (fileData != null) {
              setState(() {
                _selectedPhotoFileName = file.name;
                _selectedPhotoData = fileData;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Photo selected: ${file.name}'),
                    backgroundColor: Colors.green,
                  ),
                );
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

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    if (_locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPhotoData == null || _selectedPhotoFileName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please upload a photo')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _businessService.submitBusinessRegistration(
        businessName: _businessNameController.text.trim(),
        locations: _locations,
        discountType: _selectedDiscountType ?? 'percentage',
        discountAmount: double.parse(_discountAmountController.text),
        discountFrequency: _selectedDiscountFrequency ?? 'everyday',
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
      );

      if (mounted) {
        Navigator.pop(context);

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Success!'),
                content: const Text(
                  'Your business registration has been submitted for review. '
                  'We will contact you via email within 24-48 hours.',
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
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completion: ${(_progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Form(
                              key: _formKey,
                              onChanged: _updateProgress,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                    'Basic Business Information',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBusinessNameField(),
                                  const SizedBox(height: 20),
                                  _buildBusinessPhotoField(),
                                  const SizedBox(height: 32),

                                  _buildSectionHeader('Location Information'),
                                  const SizedBox(height: 16),
                                  _buildLocationField(),
                                  const SizedBox(height: 20),
                                  _buildLatitudeLongitudeFields(),
                                  const SizedBox(height: 32),

                                  _buildSectionHeader('Discount Details'),
                                  const SizedBox(height: 16),
                                  _buildDiscountTypeField(),
                                  const SizedBox(height: 20),
                                  _buildDiscountAmountField(),
                                  const SizedBox(height: 20),
                                  _buildDiscountFrequencyField(),
                                  const SizedBox(height: 32),

                                  _buildSectionHeader('Partnership Details'),
                                  const SizedBox(height: 16),
                                  _buildSchoolPartnershipField(),
                                  const SizedBox(height: 32),

                                  _buildSectionHeader(
                                    'Social Media & Online Presence',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSocialMediaFields(),
                                  const SizedBox(height: 32),

                                  _buildSectionHeader('Validity Period'),
                                  const SizedBox(height: 16),
                                  _buildValidityField(),
                                  const SizedBox(height: 40),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _saveDraft,
                                          child: const Text('Save as Draft'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _submitRegistration,
                                          child: const Text(
                                            'Submit for Review',
                                          ),
                                        ),
                                      ),
                                    ],
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBusinessNameField() {
    return TextFormField(
      controller: _businessNameController,
      decoration: InputDecoration(
        labelText: 'Business Name (Required)',
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
      onChanged: (_) => _updateProgress(),
    );
  }

  Widget _buildBusinessPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Photo (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (_selectedPhotoFileName != null &&
                    _selectedPhotoData != null)
                  Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      const SizedBox(height: 12),
                      Text(
                        'File selected: $_selectedPhotoFileName',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickPhotoFile,
                        icon: const Icon(Icons.edit),
                        label: const Text('Change Photo'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedPhotoFileName = null;
                            _selectedPhotoData = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      const Icon(Icons.image, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickPhotoFile,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Photo'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'JPG, PNG, WEBP • Max 5MB',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location/s (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter address...',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _locations.add(value.trim());
                      _locationController.clear();
                    });
                    _updateProgress();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                final address = _locationController.text.trim();
                if (address.isNotEmpty) {
                  setState(() {
                    _locations.add(address);
                    _locationController.clear();
                  });
                  _updateProgress();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (_locations.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'No locations added yet',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _locations[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() => _locations.removeAt(index));
                          _updateProgress();
                        },
                        splashRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLatitudeLongitudeFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _latitudeController,
            decoration: InputDecoration(
              labelText: 'Latitude',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _longitudeController,
            decoration: InputDecoration(
              labelText: 'Longitude',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Type (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: const Text('Percentage (%)'),
          value: 'percentage',
          groupValue: _selectedDiscountType,
          onChanged: (value) => setState(() => _selectedDiscountType = value),
        ),
        RadioListTile<String>(
          title: const Text('Fixed Amount (\$)'),
          value: 'fixed',
          groupValue: _selectedDiscountType,
          onChanged: (value) => setState(() => _selectedDiscountType = value),
        ),
      ],
    );
  }

  Widget _buildDiscountAmountField() {
    return TextFormField(
      controller: _discountAmountController,
      decoration: InputDecoration(
        labelText: 'Discount Amount (Required)',
        suffix: Text(_selectedDiscountType == 'percentage' ? '%' : '\$'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final num = double.tryParse(value);
        if (num == null || num <= 0) return 'Must be positive';
        if (_selectedDiscountType == 'percentage' && num > 100)
          return 'Max 100%';
        return null;
      },
      onChanged: (_) => _updateProgress(),
    );
  }

  Widget _buildDiscountFrequencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discount Frequency (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: const Text('Everyday (Renewable Daily)'),
          value: 'everyday',
          groupValue: _selectedDiscountFrequency,
          onChanged:
              (value) => setState(() => _selectedDiscountFrequency = value),
        ),
        RadioListTile<String>(
          title: const Text('Once a Week (Weekly)'),
          value: 'weekly',
          groupValue: _selectedDiscountFrequency,
          onChanged:
              (value) => setState(() => _selectedDiscountFrequency = value),
        ),
      ],
    );
  }

  Widget _buildSchoolPartnershipField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Partnership (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Offer to all partner schools'),
          value: _offerToAllSchools,
          onChanged:
              (value) => setState(() => _offerToAllSchools = value ?? true),
        ),
        if (!_offerToAllSchools)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search and select schools...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialMediaFields() {
    return Column(
      children: [
        _buildSocialMediaField('Website', _websiteController, 'https://'),
        const SizedBox(height: 12),
        _buildSocialMediaField('Facebook', _facebookController, '@'),
        const SizedBox(height: 12),
        _buildSocialMediaField('Instagram', _instagramController, '@'),
        const SizedBox(height: 12),
        _buildSocialMediaField('TikTok', _tiktokController, '@'),
        const SizedBox(height: 12),
        _buildSocialMediaField('X (Twitter)', _xController, '@'),
      ],
    );
  }

  Widget _buildSocialMediaField(
    String label,
    TextEditingController controller,
    String prefix,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildValidityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validity (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Ongoing (No end date)'),
          value: _isOngoing,
          onChanged: (value) {
            setState(() => _isOngoing = value ?? false);
            _updateProgress();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                    _updateProgress();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _startDate?.toString().split(' ')[0] ?? 'Select Start Date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (!_isOngoing)
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                      _updateProgress();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _endDate?.toString().split(' ')[0] ?? 'Select End Date',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
