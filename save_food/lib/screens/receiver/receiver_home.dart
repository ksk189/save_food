import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:save_food/screens/receiver/noti.dart';
import 'package:save_food/screens/receiver/profile.dart';
import 'package:save_food/screens/receiver/request_page.dart';
import 'package:save_food/screens/search.dart';

class ReceiverHomeScreen extends StatefulWidget {
  const ReceiverHomeScreen({Key? key}) : super(key: key);

  @override
  _ReceiverHomeScreenState createState() => _ReceiverHomeScreenState();
}

class _ReceiverHomeScreenState extends State<ReceiverHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showAllDonations = false;
  bool showAllRequests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 239, 235, 235),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReceiverProfileScreen())),
          child: CircleAvatar(
            backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
          ),
        ),
        title: Text(
          'Save Food',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 108, 172, 110),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)),
            iconSize: 35,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SearchPage())),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 13, 13, 13)),
            iconSize: 35,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => NotiPage())),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Donations',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildAvailableDonationsList(),
              const SizedBox(height: 30),
              Text('Recent Requests',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildRecentRequestsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RequestPage(
                    onAddRequest: (newRequest) => setState(() {})))),
        icon: const Icon(Icons.add),
        label: const Text('Add Request'),
        backgroundColor: const Color(0xFF66BB6A),
      ),
    );
  }

  // Method to handle donation request and get user location input
  Future<void> _handleRequestDonation(String donationId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Show a dialog to enter location details
    String locationDetails = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Your Location'),
          content: TextField(
            decoration:
                const InputDecoration(hintText: 'Enter your location details'),
            onChanged: (value) {
              locationDetails = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    // Check if location details are provided
    if (locationDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location details cannot be empty')),
      );
      return;
    }

    try {
      // Store the request and location in Firestore
      await _firestore.collection('donations').doc(donationId).update({
        'status': 'Requested',
        'requestedBy': userId,
        'locationDetails': locationDetails,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Request sent and location details shared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling request: $e')),
      );
    }
  }

  Widget _buildAvailableDonationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('donations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final donations = snapshot.data?.docs ?? [];
        final itemCount = showAllDonations ? donations.length : 2;

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final donation =
                    donations[index].data() as Map<String, dynamic>?;
                if (donation == null) return const SizedBox();

                final items = donation['items'] ?? 'Unknown Items';
                final status = donation['status'] ?? 'No Status';

                return Card(
                  child: ListTile(
                    title: Text(items),
                    subtitle: Text('Status: $status'),
                    trailing: ElevatedButton(
                      onPressed: () async =>
                          await _handleRequestDonation(donations[index].id),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text('Request'),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () =>
                  setState(() => showAllDonations = !showAllDonations),
              child: Text(showAllDonations ? 'Show Less' : 'View More'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('requests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data?.docs ?? [];
        final itemCount = showAllRequests ? requests.length : 2;

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final request = requests[index].data() as Map<String, dynamic>?;
                if (request == null) return const SizedBox();

                final items = request['items'] ?? 'Unknown Items';
                final status = request['status'] ?? 'Pending';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      items,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: $status',
                      style: GoogleFonts.poppins(color: const Color.fromARGB(255, 4, 4, 4)),
                    ),
                  ),
                );
              },
            ),
            // The View More / Show Less button
            TextButton(
              onPressed: () {
                setState(() {
                  showAllRequests = !showAllRequests;
                });
              },
              child: Text(
                showAllRequests ? 'Show Less' : 'View More',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
