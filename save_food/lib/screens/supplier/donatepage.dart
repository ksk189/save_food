import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';


class DonatePage extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddDonation;
  final List<Map<String, dynamic>> donations;

  const DonatePage({
    Key? key,
    required this.onAddDonation,
    required this.donations,
  }) : super(key: key);

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController foodItemController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedPortion;
  bool isHalal = false;
  bool isVeggie = false;
  bool isDry = false;
  bool isInstant = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitDonation() async {
    if (_formKey.currentState!.validate()) {
      final String donationId = const Uuid().v4();

      // Create the donation map
      final donation = {
        'id': donationId,
        'items': foodItemController.text.trim(),
        'portion': selectedPortion ?? 'Unknown Portion',
        'receiver': receiverController.text.trim(),
        'expirationDate': expirationDateController.text.trim(),
        'description': descriptionController.text.trim(),
        'tags': [
          if (isHalal) 'Halal',
          if (isVeggie) 'Veggie',
          if (isDry) 'Dry',
          if (isInstant) 'Instant',
        ],
        'senderName': senderNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'status': 'In Progress',
        'date': DateTime.now().toString().split(' ')[0],
      };

      try {
        // Save the donation to Firestore
        await _firestore.collection('donations').doc(donationId).set(donation);

        // Pass the donation data back to the home screen
        widget.onAddDonation(donation);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation submitted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit donation: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Create Food Donation',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Food Item Name
                _buildTextFormField('Food Item Name', controller: foodItemController),
                const SizedBox(height: 15),
                // Portion Dropdown
                _buildDropdownField(),
                const SizedBox(height: 15),
                // Receiver
                _buildTextFormField('Receiver', controller: receiverController),
                const SizedBox(height: 15),
                // Expiration Date
                _buildTextFormField('Expiration Date', hintText: 'DD/MM/YY', controller: expirationDateController),
                const SizedBox(height: 15),
                // Description
                _buildTextFormField('Description', maxLines: 3, controller: descriptionController),
                const SizedBox(height: 20),
                // Food Type Checkboxes
                Wrap(
                  spacing: 20,
                  children: [
                    _buildCheckbox('Halal', isHalal, (value) => setState(() => isHalal = value!)),
                    _buildCheckbox('Veggie', isVeggie, (value) => setState(() => isVeggie = value!)),
                    _buildCheckbox('Dry', isDry, (value) => setState(() => isDry = value!)),
                    _buildCheckbox('Instant', isInstant, (value) => setState(() => isInstant = value!)),
                  ],
                ),
                const SizedBox(height: 20),
                // Sender Information Section
                Text(
                  'Sender Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextFormField('Sender Name', controller: senderNameController),
                const SizedBox(height: 15),
                _buildTextFormField('Email', controller: emailController),
                const SizedBox(height: 15),
                _buildTextFormField('Phone', controller: phoneController),
                const SizedBox(height: 30),
                // Confirm Button
                Center(
                  child: ElevatedButton(
                    onPressed: submitDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66BB6A),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, {String hintText = '', int maxLines = 1, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedPortion,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
      ),
      hint: Text('Select Portion', style: GoogleFonts.poppins(fontSize: 14)),
      items: ['5 Servings', '10 Servings', '20 Servings']
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => setState(() => selectedPortion = value),
      validator: (value) => value == null ? 'Please select a portion' : null,
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }
}