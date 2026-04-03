import 'package:flutter/material.dart';
import 'package:idiscount_website/models/business_category.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/presenters/dashboard_presenter.dart';
import 'package:idiscount_website/services/business_service.dart';

class DashboardBusinessInformationSection extends StatelessWidget {
  final DashboardBusinessInfo businessInfo;
  final Map<String, dynamic>? registrationRecord;
  final VoidCallback onEdit;

  const DashboardBusinessInformationSection({
    super.key,
    required this.businessInfo,
    required this.registrationRecord,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessInfo.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Type: ${BusinessCategory.displayLabel(businessInfo.category)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discount: ${DashboardPresenter.formatDiscountSummary(registrationRecord)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Address: ${businessInfo.businessAddress}',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Website: ${DashboardPresenter.readValue(registrationRecord?['website'])}',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: BusinessService.getStatusColor(
                            businessInfo.submissionStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: BusinessService.getStatusColor(
                              businessInfo.submissionStatus,
                            ),
                          ),
                        ),
                        child: Text(
                          BusinessService.getStatusText(
                            businessInfo.submissionStatus,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: BusinessService.getStatusColor(
                              businessInfo.submissionStatus,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DashboardPresenter.submissionStatusMessage(
                          businessInfo.submissionStatus,
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardOfferDetailsSection extends StatelessWidget {
  final Map<String, dynamic>? registrationRecord;

  const DashboardOfferDetailsSection({
    super.key,
    required this.registrationRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Offer Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CompactStatCard(
              title: 'Discount',
              value: DashboardPresenter.formatDiscountSummary(
                registrationRecord,
              ),
              color: Colors.blue,
              icon: Icons.local_offer,
            ),
            _CompactStatCard(
              title: 'Frequency',
              value: DashboardPresenter.readValue(
                registrationRecord?['discount_frequency'],
              ),
              color: Colors.orange,
              icon: Icons.repeat,
            ),
            _CompactStatCard(
              title: 'Locations',
              value:
                  '${DashboardPresenter.asStringList(registrationRecord?['locations']).length}',
              color: Colors.green,
              icon: Icons.location_on,
            ),
            _CompactStatCard(
              title: 'Schools',
              value:
                  registrationRecord?['offer_to_all_schools'] == true
                      ? 'All'
                      : '${DashboardPresenter.asStringList(registrationRecord?['selected_schools']).length}',
              color: Colors.purple,
              icon: Icons.school,
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardRegistrationSummarySection extends StatelessWidget {
  final Map<String, dynamic>? registrationRecord;

  const DashboardRegistrationSummarySection({
    super.key,
    required this.registrationRecord,
  });

  @override
  Widget build(BuildContext context) {
    final validityText =
        registrationRecord?['is_ongoing'] == true
            ? 'Ongoing offer'
            : '${DashboardPresenter.formatDate(registrationRecord?['start_date'])} to ${DashboardPresenter.formatDate(registrationRecord?['end_date'])}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registration Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView(
            children: [
              _ActivityItem(
                title: 'Submitted',
                subtitle: DashboardPresenter.formatDate(
                  registrationRecord?['created_at'],
                ),
                icon: Icons.upload_file,
                color: Colors.indigo,
              ),
              _ActivityItem(
                title: 'Validity',
                subtitle: validityText,
                icon: Icons.date_range,
                color: Colors.blue,
              ),
              _ActivityItem(
                title: 'Channels',
                subtitle: DashboardPresenter.socialChannelsSummary(
                  registrationRecord,
                ),
                icon: Icons.campaign,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
