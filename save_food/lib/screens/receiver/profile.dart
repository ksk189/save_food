import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:save_food/screens/login_signup/login.dart';
import 'package:save_food/screens/receiver/current_requests.dart';
import 'package:save_food/screens/receiver/requesthistory.dart';
import 'package:save_food/screens/supplier/supportpage.dart';
import 'package:save_food/widgets/profile_widget.dart';
// Import your login screen

class ReceiverProfileScreen extends StatelessWidget {
  const ReceiverProfileScreen({Key? key}) : super(key: key);

  // Method to log out the user
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login page after logging out
       Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (Route<dynamic> route) => false,
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the current Firebase user
    final User? user = FirebaseAuth.instance.currentUser;

    // Get the user's display name and photo URL
    final String displayName = user?.displayName ?? 'Unknown Receiver';
    final String avatarUrl = user?.photoURL ?? 'https://example.com/receiver_avatar.png';
    final String email = user?.email ?? 'No Email';

    return ProfilePage(
      role: 'Receiver',
      avatarUrl: avatarUrl,
      name: displayName,
      email: email,
      options: [
        {
          'title': 'Request History',
          'icon': Icons.receipt_long,
          'color': Colors.teal,
          'onTap': () {
            Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RequestsHistoryPage()),
);
            // Navigate to Request History
          },
        },
        {
          'title': 'Current Requests',
          'icon': Icons.pending,
          'color': Colors.deepOrange,
          'onTap': () {
            Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CurrentRequestsPage()),
);
            // Navigate to Current Requests
          },
        },
        {
          'title': 'Contact Supplier',
          'icon': Icons.contact_phone,
          'color': Colors.indigo,
          'onTap': () {
             Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SupportPage()),
);
            // Navigate to Contact Supplier
          },
        },
        {
          'title': 'Logout',
          'icon': Icons.logout,
          'color': Colors.black,
          'onTap': () async{
       
  // Log out the user
  await FirebaseAuth.instance.signOut();

  // Navigate to the login screen and clear the navigation stack
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (Route<dynamic> route) => false, // Remove all previous routes
  );
          },
        },
      ],
    );
  }
}