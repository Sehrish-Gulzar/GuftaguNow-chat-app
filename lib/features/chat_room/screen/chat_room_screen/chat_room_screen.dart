import 'package:chat_app_with_firebase/features/chat_room/screen/chat_room_screen/widgets/chat_bubble.dart';
import 'package:chat_app_with_firebase/features/chat_room/screen/chat_room_screen/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/chat_room/chat_room_repository.dart';
import '../../../authentication/models/user_model.dart';
import '../../controller/chat_room/chat_room_controller.dart';
import '../../models/chat_rooms.dart';

class ChatRoomScreen extends StatelessWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  ChatRoomScreen(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  final ChatRoomController chatRoomController =
      Get.put(ChatRoomController(ChatRoomRepository()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(targetUser.profilePic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(targetUser.fullName.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              // This is where the chats will go
              ChatBubble(
                chatRoomController: chatRoomController,
                chatroom: chatroom,
                targetUser: targetUser,
                userModel: userModel,
              ),

              MessagesBar(
                  chatRoomController: chatRoomController,
                  userModel: userModel,
                  chatroom: chatroom,
                  targetUser: targetUser),
            ],
          ),
        ),
      ),
    );
  }
}
