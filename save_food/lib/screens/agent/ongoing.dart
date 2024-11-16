import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class OngoingDeliveriesPage extends StatefulWidget {
  const OngoingDeliveriesPage({Key? key}) : super(key: key);

  @override
  _OngoingDeliveriesPageState createState() => _OngoingDeliveriesPageState();
}

class _OngoingDeliveriesPageState extends State<OngoingDeliveriesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> ongoingDeliveries = [];

  @override
  void initState() {
    super.initState();
    fetchOngoingDeliveries();
  }

  // Fetch requests with status "Picked Up" from Firestore
  Future<void> fetchOngoingDeliveries() async {
    try {
      final querySnapshot = await _firestore
          .collection('requests')
          .where('status', isEqualTo: 'Picked Up')
          .get();

      final List<Map<String, dynamic>> deliveries = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        ongoingDeliveries = deliveries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch ongoing deliveries: $e')),
      );
    }
  }

  // Mark the request as "Delivered"
  Future<void> markAsDelivered(String requestId) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': 'Delivered',
        'deliveryDate': DateTime.now().toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as Delivered')),
      );

      fetchOngoingDeliveries(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as delivered: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Deliveries'),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: ongoingDeliveries.isEmpty
          ? Center(
              child: Text(
                'No Ongoing Deliveries',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: ongoingDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = ongoingDeliveries[index];
                return _buildOngoingDeliveryCard(delivery);
              },
            ),
    );
  }

  // Build a card for each ongoing delivery
  Widget _buildOngoingDeliveryCard(Map<String, dynamic> delivery) {
    final String items = delivery['items'] ?? 'Unknown Items';
    final String receiverName = delivery['receiverName'] ?? 'Unknown Receiver';
    final String servings = delivery['servings'] ?? 'N/A';

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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => markAsDelivered(delivery['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Mark as Delivered'),
            ),
          ],
        ),
      ),
    );
  }
}