import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Terms and Conditions of IDiscount Philippines",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text(
              "1. Acceptance of Terms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "By downloading, installing, and using the IDiscount Philippines mobile application "
              "(the “App”), you acknowledge that you have read, understood, and agreed to be bound "
              "by these Terms and Conditions, as well as our Privacy & Security Policy. "
              "If you do not agree, you must discontinue use of the App immediately.",
            ),
            SizedBox(height: 16),

            Text(
              "2. Eligibility",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "The App is intended primarily for students in the Philippines who wish to access "
              "discounts, offers, and promotions. By creating an account, you confirm that you are "
              "a student or an authorized user eligible for the services offered. Verification may "
              "be required through valid school credentials or identification.",
            ),
            SizedBox(height: 16),

            Text(
              "3. Use of Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "• You may use the App to access student-exclusive discounts, promotions, and offers from partner merchants.\n"
              "• You agree not to misuse the platform for unlawful purposes, fraud, or misrepresentation.\n"
              "• Discounts and offers are provided by third-party merchants, and their availability, terms, and conditions "
              "are determined solely by those merchants.\n"
              "• IDiscount Philippines does not guarantee the quality, accuracy, or availability of offers.",
            ),
            SizedBox(height: 16),

            Text(
              "4. User Obligations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "You agree to:\n"
              "• Provide accurate and truthful personal information\n"
              "• Keep your account credentials secure and confidential\n"
              "• Use the App responsibly and in accordance with applicable laws\n"
              "• Refrain from attempting to disrupt or compromise the App’s functionality",
            ),
            SizedBox(height: 16),

            Text(
              "5. Intellectual Property Rights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "All content, trademarks, logos, and intellectual property displayed in the App are "
              "owned by IDiscount Philippines or licensed to us. You may not copy, reproduce, "
              "or distribute any material without prior written permission.",
            ),
            SizedBox(height: 16),

            Text(
              "6. Limitation of Liability",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "IDiscount Philippines is a platform that connects students with discounts and offers. "
              "We are not responsible for:\n"
              "• The products, services, or promotions provided by partner merchants\n"
              "• Any direct, indirect, incidental, or consequential damages arising from the use of the App\n"
              "• Interruptions, errors, or loss of data due to technical issues beyond our control",
            ),
            SizedBox(height: 16),

            Text(
              "7. Termination",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We reserve the right to suspend or terminate your account at any time, with or without notice, "
              "if you violate these Terms, misuse the platform, or engage in unlawful activities.",
            ),
            SizedBox(height: 16),

            Text(
              "8. Amendments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "We may revise these Terms and Conditions from time to time. Users will be notified of significant changes "
              "through the App or via email. Continued use of the App constitutes acceptance of the updated Terms.",
            ),
            SizedBox(height: 16),

            Text(
              "9. Governing Law",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "These Terms and Conditions shall be governed by and construed in accordance with the laws of the Philippines. "
              "Any disputes shall be subject to the exclusive jurisdiction of the courts of Cebu City, Philippines.",
            ),
            SizedBox(height: 16),

            Text(
              "10. Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "For inquiries or concerns regarding these Terms, please contact us:\n\n"
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
