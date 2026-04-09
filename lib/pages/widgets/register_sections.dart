import 'package:flutter/material.dart';
import 'package:idiscount_website/models/school_option.dart';

class RegisterSectionHeader extends StatelessWidget {
  final String title;

  const RegisterSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class RegisterCityProvinceFields extends StatelessWidget {
  final TextEditingController cityMunicipalityController;
  final TextEditingController provinceController;

  const RegisterCityProvinceFields({
    super.key,
    required this.cityMunicipalityController,
    required this.provinceController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: cityMunicipalityController,
            decoration: InputDecoration(
              labelText: 'City / Municipality',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: provinceController,
            decoration: InputDecoration(
              labelText: 'Province',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterCoordinatesFields extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  const RegisterCoordinatesFields({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: latitudeController,
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
            controller: longitudeController,
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
}

class RegisterDiscountTypeField extends StatelessWidget {
  final String? selectedDiscountType;
  final ValueChanged<String?> onChanged;

  const RegisterDiscountTypeField({
    super.key,
    required this.selectedDiscountType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          groupValue: selectedDiscountType,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('Fixed Amount (\$)'),
          value: 'fixed',
          groupValue: selectedDiscountType,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class RegisterDiscountAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? selectedDiscountType;
  final ValueChanged<String> onChanged;

  const RegisterDiscountAmountField({
    super.key,
    required this.controller,
    required this.selectedDiscountType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Discount Amount (Required)',
        suffix: Text(selectedDiscountType == 'percentage' ? '%' : '\$'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final num = double.tryParse(value);
        if (num == null || num <= 0) return 'Must be positive';
        if (selectedDiscountType == 'percentage' && num > 100)
          return 'Max 100%';
        return null;
      },
      onChanged: onChanged,
    );
  }
}

class RegisterSocialMediaFields extends StatelessWidget {
  final TextEditingController websiteController;
  final TextEditingController facebookController;
  final TextEditingController instagramController;
  final TextEditingController tiktokController;
  final TextEditingController xController;

  const RegisterSocialMediaFields({
    super.key,
    required this.websiteController,
    required this.facebookController,
    required this.instagramController,
    required this.tiktokController,
    required this.xController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RegisterSocialMediaField(
          label: 'Website',
          controller: websiteController,
          prefix: 'https://',
        ),
        const SizedBox(height: 12),
        _RegisterSocialMediaField(
          label: 'Facebook',
          controller: facebookController,
          prefix: '@',
        ),
        const SizedBox(height: 12),
        _RegisterSocialMediaField(
          label: 'Instagram',
          controller: instagramController,
          prefix: '@',
        ),
        const SizedBox(height: 12),
        _RegisterSocialMediaField(
          label: 'TikTok',
          controller: tiktokController,
          prefix: '@',
        ),
        const SizedBox(height: 12),
        _RegisterSocialMediaField(
          label: 'X (Twitter)',
          controller: xController,
          prefix: '@',
        ),
      ],
    );
  }
}

class RegisterBusinessPhotoField extends StatelessWidget {
  final String? selectedPhotoFileName;
  final bool hasPhotoData;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const RegisterBusinessPhotoField({
    super.key,
    required this.selectedPhotoFileName,
    required this.hasPhotoData,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
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
                if (selectedPhotoFileName != null && hasPhotoData)
                  Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'File selected: $selectedPhotoFileName',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onPickPhoto,
                        icon: const Icon(Icons.edit),
                        label: const Text('Change Photo'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: onRemovePhoto,
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
                        onPressed: onPickPhoto,
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
}

class RegisterLocationsField extends StatelessWidget {
  final TextEditingController locationController;
  final List<String> locations;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const RegisterLocationsField({
    super.key,
    required this.locationController,
    required this.locations,
    required this.onSubmitted,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Enter address...',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (locations.isEmpty)
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
              itemCount: locations.length,
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
                          locations[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => onRemove(index),
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
}

class RegisterSchoolPartnershipField extends StatelessWidget {
  final bool offerToAllSchools;
  final List<SchoolOption> schools;
  final List<String> selectedSchools;
  final bool isLoadingSchools;
  final String? loadErrorMessage;
  final ValueChanged<bool?> onOfferToAllSchoolsChanged;
  final ValueChanged<String> onSchoolToggled;

  const RegisterSchoolPartnershipField({
    super.key,
    required this.offerToAllSchools,
    required this.schools,
    required this.selectedSchools,
    required this.isLoadingSchools,
    required this.loadErrorMessage,
    required this.onOfferToAllSchoolsChanged,
    required this.onSchoolToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School Partnership (Required)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child:
              isLoadingSchools
                  ? const Center(child: CircularProgressIndicator())
                  : loadErrorMessage != null
                  ? Text(
                    loadErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                  : schools.isEmpty
                  ? Text(
                    'No schools found.',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSchools.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Select one or more schools below.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: schools.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final school = schools[index];
                          final isSelected = selectedSchools.contains(
                            school.names,
                          );

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(school.displayLabel),
                            value: isSelected,
                            onChanged: (_) => onSchoolToggled(school.names),
                          );
                        },
                      ),
                    ],
                  ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Offer to all Schools'),
          value: offerToAllSchools,
          onChanged: onOfferToAllSchoolsChanged,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}

class RegisterValidityField extends StatelessWidget {
  final bool isOngoing;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<bool?> onToggleOngoing;
  final VoidCallback onTapStartDate;
  final VoidCallback onTapEndDate;

  const RegisterValidityField({
    super.key,
    required this.isOngoing,
    required this.startDate,
    required this.endDate,
    required this.onToggleOngoing,
    required this.onTapStartDate,
    required this.onTapEndDate,
  });

  @override
  Widget build(BuildContext context) {
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
          value: isOngoing,
          onChanged: onToggleOngoing,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTapStartDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startDate?.toString().split(' ')[0] ?? 'Select Start Date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (!isOngoing)
              Expanded(
                child: GestureDetector(
                  onTap: onTapEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      endDate?.toString().split(' ')[0] ?? 'Select End Date',
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

class RegisterFormActions extends StatelessWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  const RegisterFormActions({
    super.key,
    required this.onSaveDraft,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onSaveDraft,
            child: const Text('Save as Draft'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Submit for Review'),
          ),
        ),
      ],
    );
  }
}

class _RegisterSocialMediaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String prefix;

  const _RegisterSocialMediaField({
    required this.label,
    required this.controller,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
