import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/repositories/home/home_repository.dart';
import '../../../authentication/models/user_model.dart';

class HomeController {
  final HomeRepository homeRepository = HomeRepository();

  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return homeRepository.getUserChatRooms(userId);
  }

  Future<UserModel?> getUserModelById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        // Print retrieved data for debugging

        log('Retrieved data: ${doc.data()}');

        // Ensure that data is correctly mapped to the UserModel
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<bool> isProfileComplete(UserModel userModel) async {
    if (userModel.fullName == null || userModel.fullName!.isEmpty) return false;
    if (userModel.profilePic == null || userModel.profilePic!.isEmpty) {
      return false;
    }
    return true;
  }
}
