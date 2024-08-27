import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../features/authentication/models/user_model.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../services/firebase_storage_services.dart';
import '../authentication/authentication_repository.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SgFirebaseStorageService _storageService =
      SgFirebaseStorageService.instance;

  /// Function to save user data to Firestore
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("users").doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch user details based on user ID
  Future<UserModel> fetchUserDetails() async {
    try {
      final uid = AuthenticationRepository.instance.authUser?.uid;
      if (uid != null) {
        final documentSnapshot = await _db.collection("users").doc(uid).get();
        if (documentSnapshot.exists) {
          return UserModel.fromMap(
              documentSnapshot.data() as Map<String, dynamic>);
        }
      }
      return UserModel.empty();
      return UserModel.empty();
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update user data in Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection("users")
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update any field in specific Users collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("users")
          .doc(AuthenticationRepository.instance.authUser!.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to remove the user data from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload any Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      return await _storageService.uploadImageFile(path, File(image.path));
    } on FirebaseException catch (e) {
      throw SgFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const SgFormatException();
    } on PlatformException catch (e) {
      throw SgPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
