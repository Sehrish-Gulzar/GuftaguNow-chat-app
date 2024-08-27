import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../features/chat_room/models/chat_rooms.dart';
import '../../../main.dart';

class SearchUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserByEmail(
      String email, String currentUserEmail) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .where("email", isNotEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> userMap =
            snapshot.docs[0].data() as Map<String, dynamic>;
        return UserModel.fromMap(userMap);
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<ChatRoomModel?> getChatroomModel(
      UserModel currentUser, UserModel targetUser) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("chatrooms")
          .where("participants.${currentUser.uid}", isEqualTo: true)
          .where("participants.${targetUser.uid}", isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var docData = snapshot.docs[0].data();
        return ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      } else {
        ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            currentUser.uid.toString(): true,
            targetUser.uid.toString(): true,
          },
        );

        await _firestore
            .collection("chatrooms")
            .doc(newChatroom.chatroomid)
            .set(newChatroom.toMap());

        return newChatroom;
      }
    } catch (e) {
      print("Error fetching chatroom: $e");
      return null;
    }
  }
}
