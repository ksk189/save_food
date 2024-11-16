import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: Center(
        child: Text(
          'Chat Feature Coming Soon',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}