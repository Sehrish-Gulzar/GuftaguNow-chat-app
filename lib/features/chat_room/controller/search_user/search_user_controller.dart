import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/search_user/search_user.dart';
import '../../../authentication/models/user_model.dart';
import '../../models/chat_rooms.dart';

class SearchUserController extends GetxController {
  final searchController = TextEditingController();
  var searchResult = Rxn<UserModel>();
  var isLoading = RxBool(false);

  final SearchUserRepository repository = SearchUserRepository();

  void searchUser(UserModel currentUser) async {
    final email = searchController.text.trim();

    if (email.isNotEmpty) {
      isLoading.value = true;
      searchResult.value =
          await repository.getUserByEmail(email, currentUser.email!);
      isLoading.value = false;
    } else {
      searchResult.value = null;
    }
  }

  Future<ChatRoomModel?> getChatroomModel(
      UserModel currentUser, UserModel targetUser) async {
    return await repository.getChatroomModel(currentUser, targetUser);
  }
}
