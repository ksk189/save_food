import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

class SupplierRequestsPage extends StatelessWidget {
  const SupplierRequestsPage({Key? key}) : super(key: key);
 Future<void> _acceptRequest(DocumentSnapshot requestDoc, BuildContext context) async {
    try {
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      // Check location services and permissions
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      // Get current location
      locationData = await location.getLocation();

      // Update Firestore with status and location
      await requestDoc.reference.update({
        'status': 'Accepted',
        'location': {
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Accepted and Location Shared!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    }
  }

  // Method to reject the request
  Future<void> _rejectRequest(DocumentSnapshot requestDoc, BuildContext context) async {
    try {
      await requestDoc.reference.update({'status': 'Rejected'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Rejected!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier Requests', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No requests available.',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data() as Map<String, dynamic>;

              final String items = data['items'] ?? 'Unknown Item';
              final String portion = data['portion'] ?? 'Unknown Portion';
              final String status = data['status'] ?? 'Pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    '$items ($portion)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: $status',
                    style: GoogleFonts.poppins(
                      color: status == 'Delivered'
                          ? Colors.green
                          : status == 'Rejected'
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                  leading: const Icon(Icons.fastfood, color: Colors.green),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _acceptRequest(request, context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _rejectRequest(request, context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}