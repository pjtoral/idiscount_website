import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy & Security Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Privacy & Security Policy of IDiscount Philippines",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text(
              "1. General Statement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "IDiscount Philippines (“we,” “our,” “us”) is committed to protecting the "
              "privacy and security of all student users of our mobile application and "
              "services. This Privacy & Security Policy outlines the collection, use, "
              "storage, sharing, and protection of personal data, in compliance with the "
              "Philippine Data Privacy Act of 2012 (RA 10173) and other applicable laws.",
            ),
            SizedBox(height: 16),

            Text(
              "2. Information We Collect",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We may collect the following categories of personal and sensitive information:\n\n"
              "• Identifying Information: full name, age, date of birth\n"
              "• Contact Information: email address, mobile number (if provided)\n"
              "• Student Verification Data: school name, student ID (if required for eligibility)\n"
              "• Business Preferences: categories or industries of interest for discounts and offers\n"
              "• Technical Data: device type, operating system, IP address, app usage analytics\n"
              "• Communication Data: responses to surveys, feedback, or inquiries sent to us",
            ),
            SizedBox(height: 16),

            Text(
              "3. Purpose of Data Collection",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We collect and process your data for the following legitimate purposes:\n\n"
              "• To verify student eligibility and provide tailored discount services\n"
              "• To personalize app content and recommend offers based on preferences\n"
              "• To maintain and improve app functionality, security, and user experience\n"
              "• To communicate relevant updates, promotions, or important announcements\n"
              "• To comply with legal, regulatory, and contractual obligations\n"
              "• To prevent fraud, misuse, or unauthorized access to the platform",
            ),
            SizedBox(height: 16),

            Text(
              "4. Data Sharing and Disclosure",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We do not sell, rent, or lease your personal data to third parties. "
              "Your information may be shared only under the following circumstances:\n\n"
              "• With your consent, when you opt in to receive offers or promotions\n"
              "• With partner businesses or merchants, solely for providing relevant discounts\n"
              "• With service providers (e.g., cloud hosting, analytics) who are contractually "
              "obligated to maintain confidentiality\n"
              "• When required by law, court order, or lawful request of government authorities\n"
              "• In cases of mergers, acquisitions, or restructuring, provided adequate safeguards are in place",
            ),
            SizedBox(height: 16),

            Text(
              "5. Data Security",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We implement industry-standard organizational, physical, and technical measures "
              "to protect your personal data, including:\n\n"
              "• Encryption of data during storage and transmission\n"
              "• Restricted access to authorized personnel only\n"
              "• Regular monitoring of systems for vulnerabilities and unauthorized access\n"
              "• Secure authentication protocols to protect accounts",
            ),
            SizedBox(height: 16),

            Text(
              "6. Data Retention",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Personal data will be retained only for as long as necessary to fulfill the "
              "purposes stated in this Policy, or as required by applicable laws and regulations. "
              "When no longer needed, data will be securely deleted or anonymized.",
            ),
            SizedBox(height: 16),

            Text(
              "7. Your Rights as a Data Subject",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "In accordance with the Data Privacy Act of 2012, you have the following rights:\n\n"
              "• Right to be informed – you will be notified how your data is collected and processed\n"
              "• Right to access – you may request a copy of your personal data held by us\n"
              "• Right to rectification – you may correct or update inaccurate or incomplete data\n"
              "• Right to erasure or blocking – you may request deletion of your data\n"
              "• Right to data portability – you may obtain and reuse your personal data\n"
              "• Right to object or withdraw consent – you may opt out of certain data uses",
            ),
            SizedBox(height: 16),

            Text(
              "8. Amendments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We reserve the right to update or modify this Privacy & Security Policy at any time. "
              "Users will be notified of significant changes through the application or via email.",
            ),
            SizedBox(height: 16),

            Text(
              "9. Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "For questions, concerns, or requests regarding your data, please contact us:\n\n"
              "Data Protection Officer (DPO)\n"
              "IDiscount Philippines\n"
              "Email: idiscount.philippines@gmail.com\n",
            ),
            SizedBox(height: 30),

            Text(
              "Effective Date: September 28, 2025",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
