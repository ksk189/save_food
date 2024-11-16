import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryHistoryPage extends StatefulWidget {
  const DeliveryHistoryPage({Key? key}) : super(key: key);

  @override
  _DeliveryHistoryPageState createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> deliveredRequests = [];

  @override
  void initState() {
    super.initState();
    fetchDeliveredRequests();
  }

  // Fetch requests marked as "Delivered" from Firestore
  Future<void> fetchDeliveredRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'Delivered')
          .get();

      final List<Map<String, dynamic>> requests = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        deliveredRequests = requests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch delivery history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: deliveredRequests.isEmpty
          ? Center(
              child: Text(
                'No Delivered Requests Yet',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: deliveredRequests.length,
              itemBuilder: (context, index) {
                final request = deliveredRequests[index];
                return _buildDeliveryCard(request);
              },
            ),
    );
  }

  // Build a card for each delivered request
  Widget _buildDeliveryCard(Map<String, dynamic> request) {
    final String items = request['items'] ?? 'Unknown Items';
    final String receiverName = request['receiverName'] ?? 'Unknown Receiver';
    final String servings = request['servings'] ?? 'N/A';
    final String deliveryDate = request['deliveryDate'] ?? 'Date Not Available';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items: $items',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Receiver: $receiverName',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              'Servings: $servings',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              'Delivered On: $deliveryDate',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}