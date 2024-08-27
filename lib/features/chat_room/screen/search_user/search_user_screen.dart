import 'package:chat_app_with_firebase/utils/constants/image_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../controller/search_user/search_user_controller.dart';
import '../../models/chat_rooms.dart';
import '../chat_room_screen/chat_room_screen.dart';

class SearchUserScreen extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchUserScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    final dark = SgHelperFunctions.isDarkMode(context);

    final SearchUserController controller = Get.put(SearchUserController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: dark ? SgColors.light : SgColors.dark),
        title: const Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: controller.searchController,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    controller.searchUser(userModel);
                  },
                  child: const Text("Search"),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  // Show loading indicator while searching
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.searchResult.value == null &&
                    controller.searchController.text.isEmpty) {
                  // Show initial prompt if no search has been performed
                  return Center(
                      child: Text(
                    "Search user with email",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ));
                } else if (controller.searchResult.value == null) {
                  // Show anime image if no user is found
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        SgImages.noFound, // Update with your anime image asset
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No user found with this email.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                } else {
                  final searchResult = controller.searchResult.value!;
                  // Display the found user
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(searchResult.profilePic ?? ''),
                      backgroundColor: Colors.grey[500],
                    ),
                    title: Text(searchResult.fullName ?? 'No Name'),
                    subtitle: Text(searchResult.email ?? 'No Email'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () async {
                      ChatRoomModel? chatroomModel = await controller
                          .getChatroomModel(userModel, searchResult);

                      if (chatroomModel != null) {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChatRoomScreen(
                            targetUser: searchResult,
                            userModel: userModel,
                            firebaseUser: firebaseUser,
                            chatroom: chatroomModel,
                          );
                        }));
                      }
                    },
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
