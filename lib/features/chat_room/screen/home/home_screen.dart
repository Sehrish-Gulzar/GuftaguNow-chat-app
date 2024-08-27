import 'package:chat_app_with_firebase/data/services/firebase_storage_services.dart';
import 'package:chat_app_with_firebase/features/chat_room/screen/home/widgets/home_drawer.dart';
import 'package:chat_app_with_firebase/features/chat_room/screen/home/widgets/user_chat_rooms_stream.dart';
import 'package:chat_app_with_firebase/features/chat_room/screen/search_user/search_user_screen.dart';
import 'package:chat_app_with_firebase/utils/constants/colors.dart';
import 'package:chat_app_with_firebase/utils/constants/text_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../controller/home/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  final HomeController _homeController = HomeController();

  HomeScreen({super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    final dark = SgHelperFunctions.isDarkMode(context);
    Get.put(SgFirebaseStorageService());

    return Scaffold(
      drawer: HomeDrawer(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(SgTexts.appName),
        iconTheme: IconThemeData(color: dark ? SgColors.light : SgColors.dark),
      ),
      body: SafeArea(
        child: UserChatRoomsStream(
          userModel: userModel,
          homeController: _homeController,
          firebaseUser: firebaseUser,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SgColors.secondary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchUserScreen(
                userModel: userModel, firebaseUser: firebaseUser);
          }));
        },
        child: Icon(
          Icons.search,
          color: dark ? SgColors.white : SgColors.dark,
        ),
      ),
    );
  }
}
