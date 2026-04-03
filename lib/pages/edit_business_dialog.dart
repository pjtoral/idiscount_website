import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_category.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/models/business_profile_edit_data.dart';
import 'package:idiscount_website/services/app_error_service.dart';
import 'package:idiscount_website/viewmodels/edit_business_view_model.dart';

class EditBusinessDialog extends StatefulWidget {
  final DashboardBusinessInfo businessInfo;
  final String? initialDiscountPercentage;
  final Future<void> Function(BusinessProfileEditData) onSave;

  const EditBusinessDialog({
    Key? key,
    required this.businessInfo,
    this.initialDiscountPercentage,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditBusinessDialog> createState() => _EditBusinessDialogState();
}

class _EditBusinessDialogState extends State<EditBusinessDialog> {
  late EditBusinessViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = EditBusinessViewModel.fromBusinessInfo(
      widget.businessInfo,
      initialDiscountPercentage: widget.initialDiscountPercentage,
    );
  }

  @override
  void dispose() {
    _viewModel.disposeControllers();
    _viewModel.dispose();
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
                    controller: _viewModel.businessNameController,
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _viewModel.validateBusinessName,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _viewModel.selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items:
                        BusinessCategory.keys
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  _viewModel.formatCategoryLabel(type),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _viewModel.setCategory(value));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _viewModel.contactPersonController,
                    decoration: InputDecoration(
                      labelText: 'Contact Person',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _viewModel.validateContactPerson,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _viewModel.discountPercentageController,
                    decoration: InputDecoration(
                      labelText: 'Discount Percentage',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _viewModel.validateDiscountPercentage,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _viewModel.businessAddressController,
                    decoration: InputDecoration(
                      labelText: 'Business Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 2,
                    validator: _viewModel.validateBusinessAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _viewModel.businessEmailController,
                    decoration: InputDecoration(
                      labelText: 'Business Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _viewModel.validateBusinessEmail,
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
                        onPressed:
                            _viewModel.isSaving
                                ? null
                                : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final updatedBusiness =
                                      _viewModel.buildPayload();

                                  setState(() => _viewModel.setSaving(true));
                                  try {
                                    await widget.onSave(updatedBusiness);
                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Business information updated successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppErrorService.toMessage(
                                            e,
                                            fallback:
                                                'Failed to update business information.',
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(
                                        () => _viewModel.setSaving(false),
                                      );
                                    }
                                  }
                                },
                        child:
                            _viewModel.isSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Save Changes'),
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
