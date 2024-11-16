import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:save_food/screens/receiver/noti.dart';
import 'package:save_food/screens/search.dart';
import 'package:save_food/screens/supplier/donatepage.dart';
import 'package:save_food/screens/supplier/profile.dart';
import 'package:save_food/screens/supplier/records.dart';
import 'package:save_food/screens/supplier/requestpage.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({Key? key}) : super(key: key);

  @override
  _SupplierHomeScreenState createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> donationList = [];
  List<Map<String, dynamic>> requestList = [];

  @override
  void initState() {
    super.initState();
    fetchDonations();
    fetchRequests();
  }

  // Fetch donations from Firestore
  Future<void> fetchDonations() async {
    final snapshot = await _firestore.collection('donations').get();
    setState(() {
      donationList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }
 Future<void> _acceptRequest(String donationId) async {
    try {
      await _firestore.collection('donations').doc(donationId).update({
        'status': 'Accepted',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully!')),
      );
      fetchDonations(); // Refresh the list after accepting a request
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    }
  }

  // Fetch requests from Firestore
  Future<void> fetchRequests() async {
    final snapshot = await _firestore.collection('requests').get();
    setState(() {
      requestList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String avatarUrl =
        user?.photoURL ?? 'https://example.com/default_avatar.png';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SupplierProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/images/profile.png')
                              as ImageProvider,
                      radius: 25,
                    ),
                  ),
                  Text(
                    'Save Food',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFA5D6A7),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search,
                            size: 32, color: const Color.fromARGB(255, 24, 24, 24)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchPage()));
                        },
                      ),
                      const SizedBox(width: 15),
                            IconButton(
                        icon: Icon(Icons.notifications,
                            size: 32, color: const Color.fromARGB(255, 24, 24, 24)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NotiPage()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Navigation Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem('Records', Icons.receipt_long),
                    _buildNavItem('Requests', Icons.request_page),
                    _buildNavItem('Chats', Icons.chat),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Current Donation List Section
              Text(
                'Your Current Donation List',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildDonationList(),
              const SizedBox(height: 30),
              // Donate Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonatePage(
                          onAddDonation: (newDonation) {
                            setState(() {
                              donationList.add(newDonation);
                            });
                          },
                          donations: donationList,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Donate',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Card Builder
  Widget _buildNavItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Records') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RecordsPage(donations: donationList)));
        } else if (title == 'Requests') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SupplierRequestsPage()));
        }
        
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Donation List Builder with Accept Request Button
  Widget _buildDonationList() {
    if (donationList.isEmpty) {
      return Center(
        child: Text('No Donations Yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
      );
    }

    return Column(
      children: donationList.map((donation) {
        final String donationId = donation['id'] ?? '';
        final String items = donation['items'] ?? 'Unknown Items';
        final String portion = donation['portion'] ?? 'Unknown Portion';
        final String status = donation['status'] ?? 'Pending';

        return ListTile(
          title: Text('$items ($portion)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          subtitle: Text(
            'Status: $status',
            style: TextStyle(color: status == 'Delivered' ? Colors.green : Colors.orange),
          ),
          trailing: status == 'Requested'
              ? ElevatedButton(
                  onPressed: () => _acceptRequest(donationId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Accept'),
                )
              : const SizedBox(),
        );
      }).toList(),
    );
  }
}