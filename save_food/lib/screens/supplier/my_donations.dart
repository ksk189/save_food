import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDonationsPage extends StatefulWidget {
  const MyDonationsPage({Key? key}) : super(key: key);

  @override
  _MyDonationsPageState createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> myDonations = [];

  @override
  void initState() {
    super.initState();
    fetchMyDonations();
  }

  // Method to fetch the current user's donations from Firestore
  Future<void> fetchMyDonations() async {
    if (currentUser == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('donations')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final List<Map<String, dynamic>> donations = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        myDonations = donations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: SafeArea(
        child: myDonations.isEmpty
            ? Center(
                child: Text(
                  'No Donations Yet',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: myDonations.length,
                itemBuilder: (context, index) {
                  final donation = myDonations[index];
                  return _buildDonationCard(donation);
                },
              ),
      ),
    );
  }

  // Method to build each donation card
  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final String items = donation['items'] ?? 'Unknown Items';
    final String portion = donation['portion'] ?? 'Unknown Portion';
    final String status = donation['status'] ?? 'Pending';
    final Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(
          items,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Portion: $portion\nStatus: $status',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: Icon(
          Icons.circle,
          color: statusColor,
          size: 14,
        ),
      ),
    );
  }

  // Method to get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Accepted':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}