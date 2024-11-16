import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                'No Donation History Yet',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      '${entry['items']} (${entry['portion']})',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(entry['sender']),
                    trailing: Text(
                      entry['status'],
                      style: TextStyle(
                        color: entry['status'] == 'Delivered' ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}