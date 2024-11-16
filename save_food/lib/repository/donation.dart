import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:save_food/model/donation_model.dart';

class FirebaseRepository {
  final CollectionReference donationsCollection =
      FirebaseFirestore.instance.collection('donations');

  // Add a donation to Firestore
  Future<void> addDonation(Donation donation) async {
    try {
      await donationsCollection.doc(donation.id).set(donation.toMap());
    } catch (e) {
      print('Error adding donation: $e');
    }
  }

  // Fetch donations from Firestore
  Future<List<Donation>> getDonations() async {
    try {
      final querySnapshot = await donationsCollection.get();
      return querySnapshot.docs.map((doc) {
        return Donation.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching donations: $e');
      return [];
    }
  }
}