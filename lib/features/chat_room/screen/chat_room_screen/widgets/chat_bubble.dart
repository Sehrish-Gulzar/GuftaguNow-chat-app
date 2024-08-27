// class ChatBubble extends StatelessWidget {
//   final UserModel targetUser;
//   final ChatRoomModel chatroom;
//   final UserModel userModel;
//   final ChatRoomController chatRoomController;
//
//   const ChatBubble({
//     Key? key,
//     required this.chatRoomController,
//     required this.targetUser,
//     required this.chatroom,
//     required this.userModel,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: StreamBuilder(
//           stream: chatRoomController.getMessages(chatroom.chatroomid!),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.active) {
//               if (snapshot.hasData) {
//                 QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
//
//                 List<DocumentSnapshot> docs = dataSnapshot.docs;
//
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     MessageModel currentMessage = MessageModel.fromMap(
//                       docs[index].data() as Map<String, dynamic>,
//                     );
//
//                     bool isSentByCurrentUser =
//                         currentMessage.sender == userModel.uid;
//
//                     bool showDateChip = false;
//                     if (index == docs.length - 1) {
//                       showDateChip = true;
//                     } else {
//                       MessageModel previousMessage = MessageModel.fromMap(
//                         docs[index + 1].data() as Map<String, dynamic>,
//                       );
//                       showDateChip = currentMessage.createdon.day !=
//                           previousMessage.createdon.day;
//                     }
//
//                     return Column(
//                       crossAxisAlignment: isSentByCurrentUser
//                           ? CrossAxisAlignment.end
//                           : CrossAxisAlignment.start,
//                       children: [
//                         if (showDateChip)
//                           DateChip(
//                             date: currentMessage.createdon,
//                           ),
//                         if (currentMessage.text.isNotEmpty)
//                           Container(
//                             margin: const EdgeInsets.symmetric(vertical: 5),
//                             child: Align(
//                               alignment: isSentByCurrentUser
//                                   ? Alignment.centerRight
//                                   : Alignment.centerLeft,
//                               child: BubbleNormal(
//                                 text: currentMessage.text,
//                                 isSender: isSentByCurrentUser,
//                                 color: isSentByCurrentUser
//                                     ? Colors.grey
//                                     : Theme.of(context).colorScheme.primary,
//                                 textStyle: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         if (currentMessage.imageUrl.isNotEmpty)
//                           Container(
//                             margin: const EdgeInsets.symmetric(vertical: 5),
//                             child: Align(
//                               alignment: isSentByCurrentUser
//                                   ? Alignment.centerRight
//                                   : Alignment.centerLeft,
//                               child: BubbleNormalImage(
//                                 id: '',
//                                 image: _image(currentMessage.imageUrl),
//                                 color: isSentByCurrentUser
//                                     ? Colors.grey
//                                     : Theme.of(context).colorScheme.primary,
//                                 isSender: isSentByCurrentUser,
//                                 tail: true,
//                                 delivered: true,
//                               ),
//                             ),
//                           ),
//                       ],
//                     );
//                   },
//                 );
//               } else if (snapshot.hasError) {
//                 return const Center(
//                   child: Text(
//                       "An error occurred! Please check your internet connection."),
//                 );
//               } else {
//                 return const Center(
//                   child: Text("Say hi to your new friend"),
//                 );
//               }
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _image(imageUrl) {
//     return Container(
//       constraints: BoxConstraints(
//         minHeight: 20.0,
//         minWidth: 20.0,
//       ),
//       child: CachedNetworkImage(
//         imageUrl: imageUrl,
//         progressIndicatorBuilder: (context, url, downloadProgress) =>
//             CircularProgressIndicator(value: downloadProgress.progress),
//         errorWidget: (context, url, error) => const Icon(Icons.error),
//       ),
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_with_firebase/utils/constants/colors.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../authentication/models/user_model.dart';
import '../../../controller/chat_room/chat_room_controller.dart';
import '../../../models/chat_rooms.dart';
import '../../../models/message_model.dart';
import 'date_chip.dart';

class ChatBubble extends StatelessWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final ChatRoomController chatRoomController;

  const ChatBubble({
    super.key,
    required this.chatRoomController,
    required this.targetUser,
    required this.chatroom,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: chatRoomController.getMessages(chatroom.chatroomid!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data!;
                List<DocumentSnapshot> docs = dataSnapshot.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    MessageModel currentMessage = MessageModel.fromMap(
                      docs[index].data() as Map<String, dynamic>,
                    );

                    bool isSentByCurrentUser =
                        currentMessage.sender == userModel.uid;

                    bool showDateChip = false;
                    if (index == docs.length - 1) {
                      showDateChip = true;
                    } else {
                      MessageModel previousMessage = MessageModel.fromMap(
                        docs[index + 1].data() as Map<String, dynamic>,
                      );
                      showDateChip = currentMessage.createdon.day !=
                          previousMessage.createdon.day;
                    }

                    return Column(
                      crossAxisAlignment: isSentByCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (showDateChip)
                          DateChip(date: currentMessage.createdon),
                        if (currentMessage.text.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Align(
                              alignment: isSentByCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: BubbleNormal(
                                text: currentMessage.text,
                                isSender: isSentByCurrentUser,
                                color: isSentByCurrentUser
                                    ? Colors.grey
                                    : SgColors.primary,
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        if (currentMessage.imageUrl.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Align(
                              alignment: isSentByCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: BubbleNormalImage(
                                id: currentMessage.messageid,
                                image: _image(currentMessage.imageUrl),
                                color: isSentByCurrentUser
                                    ? Colors.grey
                                    : SgColors.primary,
                                isSender: isSentByCurrentUser,
                                tail: true,
                                // delivered: true,
                              ),
                            ),
                          ),
                        if (currentMessage.audioUrl.isNotEmpty)
                          Obx(() {
                            final position = chatRoomController.position
                                    .value[currentMessage.messageid]?.inSeconds
                                    .toDouble() ??
                                0.0;
                            final duration = chatRoomController.duration
                                    .value[currentMessage.messageid]?.inSeconds
                                    .toDouble() ??
                                0.0;

                            // Ensure duration is not zero to avoid division errors
                            final effectiveDuration =
                                duration > 0 ? duration : 1.0;
                            final effectivePosition = (position < 0.0)
                                ? 0.0
                                : (position > effectiveDuration
                                    ? effectiveDuration
                                    : position);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: BubbleNormalAudio(
                                key: ValueKey(currentMessage.messageid),
                                color: isSentByCurrentUser
                                    ? Colors.grey
                                    : SgColors.primary,
                                duration: effectiveDuration,
                                position: effectivePosition,

                                isPlaying: chatRoomController
                                        .isPlaying[currentMessage.messageid] ??
                                    false,
                                isLoading: chatRoomController.isAudioLoading[
                                        currentMessage.messageid] ??
                                    false,
                                isPause: chatRoomController
                                        .isPause[currentMessage.messageid] ??
                                    false,
                                onSeekChanged: chatRoomController.changeSeek,
                                onPlayPauseButtonClick: () =>
                                    chatRoomController.playAudio(
                                  currentMessage.audioUrl,
                                  currentMessage.messageid,
                                ),
                                // sent: true,
                                isSender: isSentByCurrentUser,
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "An error occurred! Please check your internet connection.",
                  ),
                );
              } else {
                return const Center(child: Text("Say hi to your new friend"));
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _image(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
