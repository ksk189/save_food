import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:save_food/screens/agent/delivery_history.dart';
import 'package:save_food/screens/agent/ongoing.dart';
import 'package:save_food/screens/login_signup/login.dart';

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current Firebase user
    final User? user = FirebaseAuth.instance.currentUser;

    // Get user details
    final String displayName = user?.displayName ?? 'Agent';
    final String email = user?.email ?? 'No Email';
    final String? photoUrl = user?.photoURL;

    // Determine profile image
    final ImageProvider avatarImage = (photoUrl != null && photoUrl.isNotEmpty)
        ? NetworkImage(photoUrl)
        : const AssetImage('assets/images/default_avatar.png');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Avatar
          Center(
            child: CircleAvatar(
              backgroundImage: avatarImage,
              radius: 50,
              child: photoUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          // User Name
          Text(
            displayName,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          // User Email
          Text(
            email,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          // Profile Options List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                _buildProfileOptionCard(
                  icon: Icons.history,
                  title: 'Delivery History',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DeliveryHistoryPage(),
  ),
);
                    // Navigate to Delivery History
                  },
                ),
                _buildProfileOptionCard(
                  icon: Icons.local_shipping,
                  title: 'Ongoing Deliveries',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OngoingDeliveriesPage(),
  ),
);
                    // Navigate to Ongoing Deliveries
                  },
                ),
                _buildProfileOptionCard(
                  icon: Icons.chat,
                  title: 'Chat with Support',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to Chat Screen
                  },
                ),
                _buildProfileOptionCard(
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () async {
                    // Log out the user
                    await FirebaseAuth.instance.signOut();
                    // Navigate to the login screen
                     Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a profile option item with a Card
  Widget _buildProfileOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}