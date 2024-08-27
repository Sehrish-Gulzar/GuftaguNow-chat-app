import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../features/chat_room/models/chat_rooms.dart';
import '../../../features/chat_room/models/message_model.dart';
import '../../services/firebase_storage_services.dart';

// class ChatRoomRepository {
//   ChatRoomRepository get instance => Get.find();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final SgFirebaseStorageService _storageService =
//       Get.put(SgFirebaseStorageService());
//   final uuid = Uuid();
//
//   Future<void> sendMessage(
//     UserModel userModel,
//     ChatRoomModel chatroom,
//     UserModel targetUser,
//     String message,
//     String imageUrl,
//   ) async {
//     if (message.trim().isNotEmpty || imageUrl.isNotEmpty) {
//       try {
//         MessageModel newMessage = MessageModel(
//           messageid: uuid.v1(),
//           sender: userModel.uid!,
//           createdon: DateTime.now(),
//           text: message,
//           imageUrl: imageUrl,
//           seen: false,
//           delivered: false,
//           sent: true,
//         );
//
//         await _firestore
//             .collection("chatrooms")
//             .doc(chatroom.chatroomid)
//             .collection("messages")
//             .doc(newMessage.messageid)
//             .set(newMessage.toMap());
//
//         chatroom.lastMessage = message.isNotEmpty ? message : 'Image';
//         await _firestore
//             .collection("chatrooms")
//             .doc(chatroom.chatroomid)
//             .set(chatroom.toMap());
//       } catch (e) {
//         throw e;
//       }
//     }
//   }
//
//   Stream<QuerySnapshot> getMessages(String chatroomId) {
//     return _firestore
//         .collection("chatrooms")
//         .doc(chatroomId)
//         .collection("messages")
//         .orderBy(
//           "createdon",
//           descending: true,
//         )
//         .snapshots();
//   }
//
//   Future<String> uploadImage(String path, File imageFile) async {
//     try {
//       String fileName = uuid.v1();
//       Reference ref = _storage.ref().child('$path$fileName');
//       UploadTask uploadTask = ref.putFile(imageFile);
//
//       TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//       String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//       return downloadUrl;
//     } catch (e) {
//       throw e;
//     }
//   }
// }
class ChatRoomRepository {
  ChatRoomRepository get instance => Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SgFirebaseStorageService _storageService =
      Get.put(SgFirebaseStorageService());
  final uuid = const Uuid();

  Future<void> sendMessage(
    UserModel userModel,
    ChatRoomModel chatroom,
    UserModel targetUser,
    String message,
    String imageUrl,
    String audioUrl,
    int audioDuration, // Add audioDuration parameter
  ) async {
    if (message.trim().isNotEmpty ||
        imageUrl.isNotEmpty ||
        audioUrl.isNotEmpty) {
      try {
        MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: userModel.uid!,
          createdon: DateTime.now(),
          text: message,
          imageUrl: imageUrl,
          audioUrl: audioUrl,
          duration: audioDuration, // Set the duration
          seen: false,
          delivered: false,
          sent: true,
        );

        await _firestore
            .collection("chatrooms")
            .doc(chatroom.chatroomid)
            .collection("messages")
            .doc(newMessage.messageid)
            .set(newMessage.toMap());

        if (message.isNotEmpty) {
          chatroom.lastMessage = message;
        } else if (imageUrl.isNotEmpty) {
          chatroom.lastMessage = 'Image';
        } else if (audioUrl.isNotEmpty) {
          chatroom.lastMessage = 'Audio';
        }

        await _firestore
            .collection("chatrooms")
            .doc(chatroom.chatroomid)
            .set(chatroom.toMap());
      } catch (e) {
        rethrow;
      }
    }
  }

  Stream<QuerySnapshot> getMessages(String chatroomId) {
    return _firestore
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("createdon", descending: true)
        .snapshots();
  }

  Future<String> uploadFile(String path, File file) async {
    try {
      String fileName = uuid.v1();
      Reference ref = _storage.ref().child('$path$fileName');
      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
