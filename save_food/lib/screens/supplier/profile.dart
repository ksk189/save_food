import 'package:flutter/material.dart';
import 'package:save_food/screens/login_signup/login.dart';
import 'package:save_food/screens/supplier/my_donations.dart';
import 'package:save_food/screens/supplier/supportpage.dart';
import 'package:save_food/widgets/profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
 // Import your login page

class SupplierProfileScreen extends StatelessWidget {
  const SupplierProfileScreen({Key? key}) : super(key: key);

  // Function to log out the user
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
    final String displayName = user?.displayName ?? 'Unknown User';
    final String avatarUrl = user?.photoURL ?? 'https://example.com/default_avatar.png';
    final String email = user?.email ?? 'No Email';

    return ProfilePage(
      role: 'Supplier',
      avatarUrl: avatarUrl,
      name: displayName,
      email: email,
      options: [
        {
          'title': 'My Donations',
          'icon': Icons.volunteer_activism,
          'color': Colors.red,
          'onTap': () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MyDonationsPage(),
  ),
);
            // Navigate to My Donations
          },
        },
        {
          'title': 'Support',
          'icon': Icons.support_agent,
          'color': Colors.blue,
          'onTap': () {
            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SupportPage(),
  ),
);
            // Navigate to Support
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