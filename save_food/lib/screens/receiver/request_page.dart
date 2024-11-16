import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:save_food/model/request_model.dart';
import 'package:save_food/repository/request_repository.dart';

import 'package:uuid/uuid.dart';

class RequestPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddRequest;

  const RequestPage({Key? key, required this.onAddRequest}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final RequestRepository _requestRepository = RequestRepository();
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final uuid = Uuid();

  // Method to handle form submission and save request to Firestore
  Future<void> _submitRequest() async {
    final String itemsText = _itemsController.text.trim();
    final String portionText = _portionController.text.trim();

    if (itemsText.isNotEmpty && portionText.isNotEmpty) {
      final String requestId = uuid.v4(); // Generate a unique ID for the request

      // Create a RequestModel
      final request = RequestModel(
        id: requestId,
        items: itemsText,
        portion: portionText,
        status: 'Pending',
      );

      // Add the request to Firestore using RequestRepository
      try {
        await _requestRepository.addRequest(request);
        widget.onAddRequest(request.toMap());

        // Clear the text fields
        _itemsController.clear();
        _portionController.clear();

        // Navigate back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit request. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Food', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _itemsController,
              decoration: InputDecoration(
                labelText: 'Items Needed',
                hintText: 'Enter the items you need (e.g., Rice, Bread)',
                prefixIcon: const Icon(Icons.fastfood, color: Colors.green),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _portionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Portion Size',
                hintText: 'Enter the portion size (e.g., 2 kg, 5 loaves)',
                prefixIcon: const Icon(Icons.scale, color: Colors.green),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Submit Request',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _itemsController.dispose();
    _portionController.dispose();
    super.dispose();
  }
}