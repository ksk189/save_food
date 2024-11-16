import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:save_food/chatbot.dart';
import 'package:save_food/screens/receiver/request_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Method to fetch users from Firestore
 Future<void> _fetchUsers() async {
  try {
    final querySnapshot = await _firestore.collection('users').get();
    final List<Map<String, dynamic>> fetchedUsers =
        querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': doc.id, // Include userId from Firestore document ID
        'name': data['name'] ?? 'Unknown',
        'image': data['photoUrl'] ?? 'assets/images/default_avatar.png',
        'role': data['role'] ?? 'No Role',
      };
    }).toList();

    setState(() {
      users = fetchedUsers;
      filteredUsers = users;
    });
  } catch (e) {
    print('Error fetching users: $e');
  }
}
  // Method to filter users based on search query
  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users
            .where((user) =>
                user['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA5D6A7),
        title: Text(
          'Search',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: InputDecoration(
                  hintText: 'Search for people...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // List of Users
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String userId = user['userId'];
    final String name = user['name'];
    final String imagePath = user['image'];
    final String role = user['role'];

    // Trim the name if it exceeds 15 characters
    final String trimmedName =
        name.length > 15 ? '${name.substring(0, 15)}...' : name;

    return InkWell(
      onTap: () {
        // Navigate to the ChatPage when a user card is clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatWithUserId: userId,
              chatWithUserName: name,
              chatWithUserPhotoUrl: imagePath,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Avatar
            CircleAvatar(
              backgroundImage: NetworkImage(imagePath),
              radius: 25,
              onBackgroundImageError: (_, __) {
                Image.asset('assets/images/default_avatar.png',
                    fit: BoxFit.cover);
              },
            ),
            const SizedBox(width: 15),
            // User Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trimmedName,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    role,
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
