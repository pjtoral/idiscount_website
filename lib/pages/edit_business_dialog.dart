import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_info.dart';

class EditBusinessDialog extends StatefulWidget {
  final BusinessInfo businessInfo;
  final Function(BusinessInfo) onSave;

  const EditBusinessDialog({
    Key? key,
    required this.businessInfo,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditBusinessDialog> createState() => _EditBusinessDialogState();
}

class _EditBusinessDialogState extends State<EditBusinessDialog> {
  late TextEditingController _businessNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactNumberController;
  late TextEditingController _businessAddressController;
  late TextEditingController _businessEmailController;
  late String _selectedBusinessType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(
      text: widget.businessInfo.businessName,
    );
    _contactPersonController = TextEditingController(
      text: widget.businessInfo.contactPerson,
    );
    _contactNumberController = TextEditingController(
      text: widget.businessInfo.contactNumber,
    );
    _businessAddressController = TextEditingController(
      text: widget.businessInfo.businessAddress,
    );
    _businessEmailController = TextEditingController(
      text: widget.businessInfo.businessEmail,
    );
    _selectedBusinessType = widget.businessInfo.businessType;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _businessAddressController.dispose();
    _businessEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Business Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Business name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBusinessType,
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        [
                              'Retail',
                              'Service',
                              'Manufacturing',
                              'Wholesale',
                              'Food & Beverage',
                              'Technology',
                              'Other',
                            ]
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBusinessType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: InputDecoration(
                      labelText: 'Contact Person',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact person is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessAddressController,
                    decoration: InputDecoration(
                      labelText: 'Business Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Business address is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _businessEmailController,
                    decoration: InputDecoration(
                      labelText: 'Business Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Business email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final updatedBusiness = widget.businessInfo
                                .copyWith(
                                  businessName: _businessNameController.text,
                                  businessType: _selectedBusinessType,
                                  contactPerson: _contactPersonController.text,
                                  contactNumber: _contactNumberController.text,
                                  businessAddress:
                                      _businessAddressController.text,
                                  businessEmail: _businessEmailController.text,
                                );
                            widget.onSave(updatedBusiness);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Business information updated successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
