import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  final String role;
  final String avatarUrl;
  final String name;
  final String email;
  final List<Map<String, dynamic>> options;

  const ProfilePage({
    Key? key,
    required this.role,
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.options,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$role Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Circular Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            const SizedBox(height: 20),
            // Name and Email
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Profile Options List
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: option['color'],
                        child: Icon(
                          option['icon'],
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        option['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: option['onTap'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}