import 'package:chat_app_with_firebase/utils/constants/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../controller/chat_room/chat_room_controller.dart';
import '../../../models/chat_rooms.dart';

class MessagesBar extends StatelessWidget {
  const MessagesBar({
    super.key,
    required this.chatRoomController,
    required this.userModel,
    required this.chatroom,
    required this.targetUser,
  });

  final ChatRoomController chatRoomController;
  final UserModel userModel;
  final ChatRoomModel chatroom;
  final UserModel targetUser;

  @override
  Widget build(BuildContext context) {
    final dark = SgHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              InkWell(
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24,
                ),
                onTap: () {
                  // Handle additional action
                },
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: InkWell(
                  onTap: chatRoomController.toggleEmojiPicker,
                  child: const Icon(
                    Icons.emoji_emotions,
                    color: SgColors.secondary,
                    size: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: InkWell(
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.green,
                    size: 24,
                  ),
                  onTap: () {
                    chatRoomController.selectImage(
                        userModel, chatroom, targetUser,
                        context: context);
                  },
                ),
              ),
              Flexible(
                child: TextField(
                  controller: chatRoomController.messageController,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Type your message here",
                    hintStyle: const TextStyle(
                        color: SgColors.dark, fontWeight: FontWeight.w400),
                    hintMaxLines: 1,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 10),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 0.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(
                        color: Colors.black26,
                        width: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  chatRoomController.startRecording();
                },
                onLongPressUp: () {
                  chatRoomController.stopRecording(
                      userModel, chatroom, targetUser);
                },
                child: const Icon(
                  Icons.mic,
                  color: SgColors.dark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: InkWell(
                  child: Obx(() => chatRoomController.isLoading.value
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: () {
                            String message = chatRoomController
                                .messageController.text
                                .trim();
                            if (message.isNotEmpty) {
                              chatRoomController.sendMessage(
                                userModel,
                                chatroom,
                                targetUser,
                                message: message,
                              );
                            }
                          },
                          icon: const Icon(Icons.send, color: Colors.blue),
                        )),
                  onTap: () {
                    String message =
                        chatRoomController.messageController.text.trim();
                    if (message.isNotEmpty) {
                      chatRoomController.sendMessage(
                        userModel,
                        chatroom,
                        targetUser,
                        message: message,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Obx(() => chatRoomController.emojiShowing.value
            ? Offstage(
                offstage: !chatRoomController.emojiShowing.value,
                child: EmojiPicker(
                  textEditingController: chatRoomController.messageController,
                  scrollController: chatRoomController.scrollController,
                  config: const Config(
                    checkPlatformCompatibility: true,
                    swapCategoryAndBottomBar: false,
                    bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: SgColors.primary,
                        buttonColor: SgColors.primary),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}
