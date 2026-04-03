import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/models/dashboard_business_info.dart';
import 'package:idiscount_website/pages/widgets/dashboard_chrome.dart';
import 'package:idiscount_website/pages/widgets/dashboard_sections.dart';
import 'package:idiscount_website/viewmodels/dashboard_view_model.dart';
import 'package:idiscount_website/pages/edit_business_dialog.dart';

class DashboardPage extends StatefulWidget {
  final String userEmail;

  const DashboardPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardViewModel _viewModel;

  DashboardBusinessInfo? get _businessInfo => _viewModel.businessInfo;
  Map<String, dynamic>? get _registrationRecord =>
      _viewModel.registrationRecord;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _loadDashboard();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    final loadState = await _viewModel.loadDashboardData();
    if (!mounted) return;

    if (loadState == DashboardLoadState.needsRegistration) {
      context.go('/register');
      return;
    }

    if (loadState == DashboardLoadState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.errorMessage ?? 'Error loading dashboard data.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {});
  }

  void _openEditDialog() {
    final businessInfo = _businessInfo;
    if (businessInfo == null) return;

    showDialog(
      context: context,
      builder:
          (context) => EditBusinessDialog(
            businessInfo: businessInfo,
            initialDiscountPercentage: _viewModel.extractPercentageDiscount(),
            onSave: (updatedInfo) async {
              await _viewModel.saveProfileEdits(updatedInfo);
              if (mounted) {
                setState(() {});
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final businessInfo = _businessInfo;
    if (businessInfo == null) {
      return const Scaffold(
        body: Center(child: Text('No business data found.')),
      );
    }

    return Scaffold(
      appBar: DashboardAppBar(
        userEmail: widget.userEmail,
        onLogoutTap: () {
          showDashboardLogoutDialog(
            context,
            onConfirmLogout: () => context.go('/login'),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardWelcomeHeader(userEmail: widget.userEmail),
              const SizedBox(height: 40),
              DashboardBusinessInformationSection(
                businessInfo: businessInfo,
                registrationRecord: _registrationRecord,
                onEdit: _openEditDialog,
              ),
              const SizedBox(height: 40),
              DashboardOfferDetailsSection(
                registrationRecord: _registrationRecord,
              ),
              const SizedBox(height: 40),
              DashboardRegistrationSummarySection(
                registrationRecord: _registrationRecord,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
