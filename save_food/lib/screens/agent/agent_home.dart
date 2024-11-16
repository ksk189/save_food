import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:save_food/screens/agent/notification.dart';
import 'package:save_food/screens/agent/profile.dart';
import 'package:save_food/screens/search.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({Key? key}) : super(key: key);

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> acceptedRequests = [];
  List<Map<String, dynamic>> pendingDeliveries = [];

@override
void initState() {
  super.initState();
  fetchAcceptedRequests();
  fetchPendingDeliveries();
  fetchAcceptedDonations(); // Fetch accepted donations
}
  Future<void> fetchAcceptedDonations() async {
  try {
    final querySnapshot = await _firestore
        .collection('donations')
        .where('status', isEqualTo: 'Accepted')
        .get();

    final List<Map<String, dynamic>> donations = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['items'] = data['items']?.toString() ?? 'Unknown Items';
      data['servings'] = data['servings']?.toString() ?? 'N/A';
      data['senderName'] = data['senderName']?.toString() ?? 'Unknown Sender';
      return data;
    }).toList();

    setState(() {
      acceptedRequests.addAll(donations);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch accepted donations: $e')),
    );
  }
}

  // Fetch accepted requests from Firestore
  Future<void> fetchAcceptedRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'Accepted')
          .get();

      final List<Map<String, dynamic>> requests = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        acceptedRequests = requests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch accepted requests: $e')),
      );
    }
  }

  // Fetch pending deliveries from Firestore
  Future<void> fetchPendingDeliveries() async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'Picked Up')
          .get();

      final List<Map<String, dynamic>> deliveries =
          querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        pendingDeliveries = deliveries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch pending deliveries: $e')),
      );
    }
  }

  // Handle Pickup Action
  Future<void> handlePickUp(Map<String, dynamic> data) async {
    final location = data['location'];
    if (location != null &&
        location['latitude'] != null &&
        location['longitude'] != null) {
      await navigateToLocation(location);
      bool? confirmPickup = await showConfirmationDialog(
          'Confirm Pickup', 'Have you picked up the donation?');
      if (confirmPickup == true) {
        updateRequestStatus(data['id'], 'Picked Up');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup location not available')),
      );
    }
  }

  // Handle Delivery Action
  Future<void> handleDelivery(Map<String, dynamic> data) async {
    final location = data['location'];
    if (location != null &&
        location['latitude'] != null &&
        location['longitude'] != null) {
      await navigateToLocation(location);
      bool? confirmDelivery = await showConfirmationDialog(
          'Confirm Delivery', 'Have you delivered the donation?');
      if (confirmDelivery == true) {
        updateRequestStatus(data['id'], 'Delivered');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery location not available')),
      );
    }
  }

  // Navigate to Location using Google Maps
  Future<void> navigateToLocation(Map<String, dynamic> location) async {
    final latitude = location['latitude'];
    final longitude = location['longitude'];
    final Uri googleMapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');

    if (await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
      print('Launching Google Maps...');
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': newStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request updated to $newStatus')),
      );

      fetchAcceptedRequests();
      fetchPendingDeliveries();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  // Show Confirmation Dialog
  Future<bool?> showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm')),
        ],
      ),
    );
  }
Widget _buildAcceptedRequestsTab() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          'Pickup List',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: acceptedRequests.length,
          itemBuilder: (context, index) {
            final request = acceptedRequests[index];
            return _buildRequestCard(request, 'Pick Up', handlePickUp);
          },
        ),
      ),
    ],
  );
}

  // Pending Deliveries Tab
  Widget _buildPendingDeliveriesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('Delivery List',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pendingDeliveries.length,
            itemBuilder: (context, index) {
              final delivery = pendingDeliveries[index];
              return _buildRequestCard(delivery, 'Deliver', handleDelivery);
            },
          ),
        ),
      ],
    );
  }

  // Card Builder
  Widget _buildRequestCard(Map<String, dynamic> data, String buttonText,
      Function(Map<String, dynamic>) action) {
    final name = buttonText == 'Pick Up'
        ? data['senderName'] ?? 'Unknown Sender'
        : data['receiverName'] ?? 'Unknown Receiver';
    final servings = data['servings'] ?? 'N/A';
    final items = data['items'] ?? 'Unknown Items';

 return Card(
  margin: const EdgeInsets.symmetric(vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  elevation: 4,
  child: ListTile(
    contentPadding: const EdgeInsets.all(16),
    title: Text(
      items,
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    ),
    subtitle: Text('$name\nServings: $servings'),
    trailing: ElevatedButton(
      onPressed: () => action(data),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonText == 'Pick Up' ? Colors.blue : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(buttonText),
    ),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  title: Text(
    'Agent Dashboard',
    style: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              iconSize: 35,
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SearchPage()))),
          IconButton(
              icon: const Icon(Icons.notifications),
              iconSize: 35,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AgentNotificationPage()))),
        ],
    leading: Padding(
  padding: const EdgeInsets.all(8.0),
  child: GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgentProfileScreen()),
    ),
    child: CircleAvatar(
      radius: 25,
      backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
          ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
      child: FirebaseAuth.instance.currentUser?.photoURL == null
          ? const Icon(Icons.person, color: Colors.white)
          : null,
    ),
  ),
),
      ),
      body: SafeArea(
       child: Column(
  children: [
Expanded(
  flex: 1,
  child: Container(
    color: const Color.fromARGB(255, 168, 209, 236), // Light blue background for Pickup List
    child: _buildAcceptedRequestsTab(),
  ),
),
const SizedBox(height: 6), // Spacer between the sections
Container(
  height: 5,
  color: Colors.grey[300], // Light grey divider
),
const SizedBox(height:15), // Spacer after the divider
Expanded(
  flex: 1,
  child: Container(
    color: const Color.fromARGB(255, 181, 216, 142), // Light green background for Delivery List
    child: _buildPendingDeliveriesTab(),
  ),
),
  ],
),
      ),
    );
  }
}
