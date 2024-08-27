import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/authentication/models/user_model.dart';

class HomeRepository {
  HomeRepository get instance => Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection("chatrooms")
        .where("participants.$userId", isEqualTo: true)
        .snapshots();
  }

  Future<UserModel?> getUserModelById(String userId) async {
    DocumentSnapshot docSnapshot =
        await _firestore.collection("users").doc(userId).get();
    if (docSnapshot.exists) {
      return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }
}
