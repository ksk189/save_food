import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:save_food/model/request_model.dart';


class RequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a new request to Firestore
  Future<void> addRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').doc(request.id).set(request.toMap());
      print('Request added successfully');
    } catch (e) {
      print('Error adding request: $e');
      rethrow;
    }
  }

  // Method to retrieve all requests from Firestore
  Future<List<RequestModel>> getRequests() async {
    try {
      final querySnapshot = await _firestore.collection('requests').get();
      return querySnapshot.docs.map((doc) => RequestModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error fetching requests: $e');
      rethrow;
    }
  }
}