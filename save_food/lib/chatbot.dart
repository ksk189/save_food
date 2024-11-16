import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String chatWithUserId;
  final String chatWithUserName;
  final String chatWithUserPhotoUrl;

  const ChatPage({
    Key? key,
    required this.chatWithUserId,
    required this.chatWithUserName,
    required this.chatWithUserPhotoUrl,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  late String currentUserId;
  late String chatId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    chatId = getChatId(currentUserId, widget.chatWithUserId);
  }

  // Generate chat ID based on user IDs
  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';
  }

  // Send a message
  Future<void> sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'receiverId': widget.chatWithUserId,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  // Chat UI
  Widget buildMessage(Map<String, dynamic> messageData) {
    final bool isMe = messageData['senderId'] == currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          messageData['message'],
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ),
    );
  }

  // Fetch messages
  Widget buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            return buildMessage(messageData);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.chatWithUserPhotoUrl.isNotEmpty
                  ? NetworkImage(widget.chatWithUserPhotoUrl)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(widget.chatWithUserName, style: GoogleFonts.poppins()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: buildMessagesList()),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}