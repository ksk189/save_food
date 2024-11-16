import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Save Food Support!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF66BB6A),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'How the App Works:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '1. As a Supplier:\n'
                '- You can donate surplus food by adding a donation request.\n'
                '- Track the status of your donations in the "My Donations" section.\n'
                '- View requests from receivers and accept them if needed.\n',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '2. As a Receiver:\n'
                '- Search for available donations and request items you need.\n'
                '- Keep track of your requests in the "Recent Requests" section.\n'
                '- Share your location details for easy pickup by the agent.\n',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                '3. As an Agent:\n'
                '- View accepted requests and donations for pickup and delivery.\n'
                '- Navigate to the provided location using Google Maps.\n'
                '- Mark requests as "Picked Up" or "Delivered" once completed.\n',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Text(
                'Need Help?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If you have any questions or need assistance, please reach out to our support team. We are here to help you with any issues you may encounter while using the app.',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open email support
                    _launchEmailSupport();
                  },
                  icon: const Icon(Icons.email, color: Colors.white),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to launch email support
  void _launchEmailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@savefood.com',
      query: 'subject=Support Request&body=Describe your issue here...',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      debugPrint('Could not launch email support: $e');
    }
  }
}