import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
  });
}

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(Message message, String chatId) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': message.senderId,
        'recipientId': message.recipientId,
        'text': message.text,
        'timestamp': message.timestamp,
        'chatId': chatId,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

class ChatScreen extends StatefulWidget {
  final String recipientUid;

  ChatScreen({
    required this.recipientUid,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? chatId;
  List<Message> _chatMessages = [];
  late Timer _chatRefreshTimer;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      final currentUserUid = user.uid;
      chatId = currentUserUid.hashCode <= widget.recipientUid.hashCode
          ? '$currentUserUid-${widget.recipientUid}'
          : '${widget.recipientUid}-$currentUserUid';
      _initializeChatMessages();
      // Start a timer to refresh chat messages every 5 seconds.
      _chatRefreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        _initializeChatMessages();
      });
    }
  }

  Future<void> _initializeChatMessages() async {
    final messages = await _messageService.getChatMessages(chatId!).first;
    _chatMessages = messages.docs.map((message) {
      return Message(
        senderId: message['senderId'],
        recipientId: message['recipientId'],
        text: message['text'],
        timestamp: message['timestamp'].toDate(),
      );
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _chatRefreshTimer.cancel(); // Cancel the timer when disposing the screen.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('You must be logged in to use this feature.'),
        ),
      );
    }

    final currentUserUid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isCurrentUser = message.senderId == currentUserUid;
                final bubbleColor = isCurrentUser ? Colors.green : Colors.blue;

                return Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        message.text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      final message = Message(
                        senderId: currentUserUid,
                        recipientId: widget.recipientUid,
                        text: text,
                        timestamp: DateTime.now(),
                      );
                      _messageService.sendMessage(message, chatId!);
                      _messageController.clear();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


