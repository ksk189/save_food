import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordsPage extends StatelessWidget {
  final List<Map<String, dynamic>> donations;

  const RecordsPage({Key? key, required this.donations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:    Text(
                'Donation History',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header with Back Button
             
              
              // Donation History Title
           
              const SizedBox(height: 10),
              // Donation History List from Firebase
              _buildDonationHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  // Fetch and Display Donations with Swipe-to-Delete
  Widget _buildDonationHistoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('donations').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No Donation History Available',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final donations = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final doc = donations[index];
            final data = doc.data() as Map<String, dynamic>;

            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _confirmDelete(context);
              },
              onDismissed: (direction) async {
                await _deleteDonation(doc.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donation deleted successfully')),
                );
              },
              child: _buildDonationHistory(
                date: data['date'] ?? 'Unknown Date',
                items: data['items'] ?? 'No Items',
                organization: data['receiver'] ?? 'No Receiver',
                tags: List<String>.from(data['tags'] ?? []),
                status: data['status'] ?? 'In Progress',
                statusColor: data['status'] == 'Delivered' ? Colors.green : Colors.orange,
              ),
            );
          },
        );
      },
    );
  }

  // Confirm Delete Dialog
  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Donation'),
        content: const Text('Are you sure you want to delete this donation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete Donation from Firestore
  Future<void> _deleteDonation(String donationId) async {
    try {
      await FirebaseFirestore.instance.collection('donations').doc(donationId).delete();
    } catch (e) {
      print('Error deleting donation: $e');
    }
  }

  Widget _buildDonationHistory({
    required String date,
    required String items,
    required String organization,
    required List<String> tags,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                items,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            organization,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (String tag in tags)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green[100],
                  ),
                ),
              const Spacer(),
              Text(
                status,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}