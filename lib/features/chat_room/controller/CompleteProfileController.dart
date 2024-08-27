import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../authentication/models/user_model.dart';
import '../screen/home/home_screen.dart';

class CompleteProfileController extends GetxController {
  var imageFile = Rx<File?>(null);
  var fullNameController = TextEditingController();
  late String initialFullName;
  late String? initialProfilePic;
  var isLoading = false.obs;

  final UserModel userModel;
  final User firebaseUser;
  final userRepository = Get.put(UserRepository());

  CompleteProfileController(this.userModel, this.firebaseUser);

  @override
  void onInit() {
    super.onInit();
    fullNameController.text = userModel.fullName ?? '';
    initialFullName = userModel.fullName ?? '';
    initialProfilePic = userModel.profilePic;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    super.onClose();
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (croppedImage != null) {
      imageFile.value = File(croppedImage.path);
    }
  }

  bool hasChanges() {
    return fullNameController.text.trim() != initialFullName ||
        imageFile.value != null ||
        (userModel.profilePic == null && initialProfilePic != null) ||
        (userModel.profilePic != null &&
            userModel.profilePic != initialProfilePic);
  }

  Future<void> uploadData() async {
    isLoading.value = true; // Start loading
    try {
      String? imageUrl = userModel.profilePic;

      if (imageFile.value != null) {
        XFile xFile = XFile(imageFile.value!.path);
        imageUrl =
            await userRepository.uploadImage('Users/Images/Profile/', xFile);
      }

      String fullname = fullNameController.text.trim();

      UserModel updatedUser = UserModel(
        uid: userModel.uid,
        email: userModel.email,
        fullName: fullname,
        profilePic: imageUrl,
      );

      await userRepository.updateUserDetails(updatedUser);
      SgHelperFunctions.successSnackBar(title: "Data Updated");
      Get.offAll(
          () => HomeScreen(userModel: updatedUser, firebaseUser: firebaseUser));
    } catch (e) {
      SgHelperFunctions.errorSnackBar(
          title: 'Error',
          message:
              'Something went wrong while updating your profile. Please try again.');
    } finally {
      isLoading.value = false; // End loading
    }
  }

  void showPhotoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
              ),
            ],
          ),
        );
      },
    );
  }
}
