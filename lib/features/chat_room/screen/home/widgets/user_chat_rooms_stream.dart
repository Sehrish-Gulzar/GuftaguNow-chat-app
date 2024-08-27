import 'package:chat_app_with_firebase/utils/constants/image_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../controller/home/home_controller.dart';
import '../../../models/chat_rooms.dart';
import '../../chat_room_screen/chat_room_screen.dart';

class UserChatRoomsStream extends StatelessWidget {
  final UserModel userModel;
  final HomeController homeController;
  final User firebaseUser;

  const UserChatRoomsStream({
    super.key,
    required this.userModel,
    required this.homeController,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: homeController.getUserChatRooms(userModel.uid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

            return ListView.builder(
              itemCount: chatRoomSnapshot.docs.length,
              itemBuilder: (context, index) {
                ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                  chatRoomSnapshot.docs[index].data() as Map<String, dynamic>,
                );

                Map<String, dynamic> participants = chatRoomModel.participants!;
                List<String> participantKeys = participants.keys.toList();
                participantKeys.remove(userModel.uid);

                return FutureBuilder(
                  future: homeController.getUserModelById(participantKeys[0]),
                  builder: (context, userData) {
                    if (userData.connectionState == ConnectionState.done) {
                      if (userData.data != null) {
                        UserModel targetUser = userData.data as UserModel;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChatRoomScreen(
                                  chatroom: chatRoomModel,
                                  firebaseUser: firebaseUser,
                                  userModel: userModel,
                                  targetUser: targetUser,
                                );
                              }),
                            );
                          },
                          leading: targetUser.profilePic != null &&
                                  targetUser.profilePic!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(targetUser.profilePic!),
                                )
                              : const CircleAvatar(
                                  backgroundImage:
                                      AssetImage(SgImages.user),
                                ),
                          title: Text(targetUser.fullName ?? 'No Name'),
                          subtitle: chatRoomModel.lastMessage != null &&
                                  chatRoomModel.lastMessage!.isNotEmpty
                              ? Text(chatRoomModel.lastMessage!)
                              : Text(
                                  "Say hi to your new friend!",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "User data is null",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        );
                      }
                    } else {
                      // Show shimmer effect while loading user data
                      return ListTile(
                        leading: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        title: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 10,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 150,
                            height: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            // Display "No Chats" when there are no chat rooms
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    SgImages.noChats,
                    scale: 6,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Center(
                      child: Text(
                        "No Conversation",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    subtitle: Center(
                      child: Text(
                        "There are no chats in your feed",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          // Show shimmer effect while the chat rooms are loading
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                  ),
                  title: Container(
                    width: 100,
                    height: 10,
                    color: Colors.grey,
                  ),
                  subtitle: Container(
                    width: 150,
                    height: 10,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
