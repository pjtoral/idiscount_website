import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/models/business_info.dart';
import 'package:idiscount_website/services/business_service.dart';
import 'package:idiscount_website/pages/edit_business_dialog.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;

  const DashboardPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late BusinessInfo businessInfo;
  final businessService = BusinessService();
  Map<String, dynamic>? _registrationRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationAndLoadData();
  }

  Future<void> _checkRegistrationAndLoadData() async {
    try {
      final hasCompleted = await businessService.hasCompletedRegistration();

      if (!hasCompleted && mounted) {
        context.go('/register');
        return;
      }

      final loadedInfo = await businessService.getBusinessInfo();
      final registrationRecord =
          await businessService.getLatestRegistrationRecord();

      if (!mounted) return;

      if ((loadedInfo == null || registrationRecord == null)) {
        context.go('/register');
        return;
      }

      businessInfo = loadedInfo!;
      _registrationRecord = registrationRecord!;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openEditDialog() {
    showDialog(
      context: context,
      builder:
          (context) => EditBusinessDialog(
            businessInfo: businessInfo,
            onSave: (updatedInfo) {
              setState(() {
                businessInfo = updatedInfo;
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                widget.userEmail,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.userEmail,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
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
                                'Type: ${businessInfo.businessType}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discount: ${_formatDiscountSummary()}',
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
                                'Website: ${_readValue(_registrationRecord?['website'])}',
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
                              onPressed: _openEditDialog,
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
                              businessInfo.submissionStatus == 'pending'
                                  ? 'Your business is under review. We will notify you once approved.'
                                  : businessInfo.submissionStatus == 'approved'
                                  ? 'Your business has been approved! You can now offer discounts.'
                                  : 'Your submission was rejected. Please contact support.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Offer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCompactStatCard(
                    'Discount',
                    _formatDiscountSummary(),
                    Colors.blue,
                    Icons.local_offer,
                  ),
                  _buildCompactStatCard(
                    'Frequency',
                    _readValue(_registrationRecord?['discount_frequency']),
                    Colors.orange,
                    Icons.repeat,
                  ),
                  _buildCompactStatCard(
                    'Locations',
                    '${_asStringList(_registrationRecord?['locations']).length}',
                    Colors.green,
                    Icons.location_on,
                  ),
                  _buildCompactStatCard(
                    'Schools',
                    _registrationRecord?['offer_to_all_schools'] == true
                        ? 'All'
                        : '${_asStringList(_registrationRecord?['selected_schools']).length}',
                    Colors.purple,
                    Icons.school,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Registration Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView(
                  children: [
                    _buildActivityItem(
                      'Submitted',
                      _formatDate(_registrationRecord?['created_at']),
                      Icons.upload_file,
                      Colors.indigo,
                    ),
                    _buildActivityItem(
                      'Validity',
                      _registrationRecord?['is_ongoing'] == true
                          ? 'Ongoing offer'
                          : '${_formatDate(_registrationRecord?['start_date'])} to ${_formatDate(_registrationRecord?['end_date'])}',
                      Icons.date_range,
                      Colors.blue,
                    ),
                    _buildActivityItem(
                      'Channels',
                      _socialChannelsSummary(),
                      Icons.campaign,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
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

  String _formatDiscountSummary() {
    final amount = _registrationRecord?['discount_amount'];
    final type = (_registrationRecord?['discount_type'] ?? '').toString();

    if (amount == null) return 'N/A';

    final formattedAmount = amount.toString();
    if (type == 'percentage') {
      return '$formattedAmount%';
    }
    if (type == 'fixed') {
      return '₱$formattedAmount';
    }
    return '$formattedAmount ${type.isEmpty ? '' : type}';
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final raw = value.toString();
    if (raw.isEmpty) return 'N/A';
    return raw.split('T').first;
  }

  String _readValue(dynamic value) {
    if (value == null) return 'N/A';
    final text = value.toString().trim();
    return text.isEmpty ? 'N/A' : text;
  }

  List<String> _asStringList(dynamic value) {
    if (value == null || value is! List) return [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  String _socialChannelsSummary() {
    final channels = <String>[];
    if (_readValue(_registrationRecord?['website']) != 'N/A') {
      channels.add('Website');
    }
    if (_readValue(_registrationRecord?['facebook']) != 'N/A') {
      channels.add('Facebook');
    }
    if (_readValue(_registrationRecord?['instagram']) != 'N/A') {
      channels.add('Instagram');
    }
    if (_readValue(_registrationRecord?['tiktok']) != 'N/A') {
      channels.add('TikTok');
    }
    if (_readValue(_registrationRecord?['x']) != 'N/A') {
      channels.add('X');
    }

    return channels.isEmpty ? 'No social channels added' : channels.join(' • ');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
