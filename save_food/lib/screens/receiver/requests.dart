import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Requests', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No requests yet.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final requests = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];

              // Safely access map values with null checks
              final String items = (item['items'] ?? 'Unknown Item') as String;
              final String portion = (item['portion'] ?? 'Unknown Portion') as String;
              final String status = (item['status'] ?? 'Pending') as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    '$items ($portion)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: status == 'Delivered' ? Colors.green : Colors.orange,
                    ),
                  ),
                  leading: const Icon(Icons.fastfood, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}