import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../authentication/models/user_model.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  /// Variables
  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());

  final imageUploading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user record from any registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      // First update Rx User and then check if user data is already stored. If not store new data
      await fetchUserRecord();

      // If no record already stored
      if (user.value.uid!.isEmpty) {
        if (userCredentials != null) {
          // Convert Full Name to First and Last Name

          // Map Data
          final user = UserModel(
              uid: userCredentials.user!.uid,
              fullName: userCredentials.user!.displayName.toString(),
              email: userCredentials.user!.email ?? '',
              // phoneNumber: userCredentials.user!.phoneNumber ?? '',
              profilePic: userCredentials.user!.photoURL ?? '');

          // Save user Record
          await userRepository.saveUserRecord(user);
        }
      }
    } catch (e) {
      SgHelperFunctions.warningSnackBar(
          title: 'Data not saved',
          message:
              'Something went wrong while saving your information. You can re-save your data in your profile.');
    }
  }

  /// Delete Account Warning
  // void deleteAccountWarningPopup() {
  //   Get.defaultDialog(
  //       contentPadding: const EdgeInsets.all(SgSizes.md),
  //       title: 'Delete Account',
  //       middleText:
  //           'Are you sure you want to delete account Permanently? This action is not reversible and all of your data will be removed permanently.',
  //       confirm: ElevatedButton(
  //           onPressed: () async => deleteUserAccount(),
  //           style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               side: const BorderSide(color: Colors.red)),
  //           child: const Padding(
  //             padding: EdgeInsets.symmetric(horizontal: SgSizes.lg),
  //             child: Text('Delete'),
  //           )),
  //       cancel: OutlinedButton(
  //           onPressed: () => Navigator.of(Get.overlayContext!).pop(),
  //           child: const Text('Cancel')));
  // }

  /// Delete User Account
  // void deleteUserAccount() async {
  //   try {
  //     SgFullScreenLoader.openLoadingDialog(
  //         'Processing', SgImages.docerAnimation);
  //
  //     /// First Re-Authenticate User
  //     final auth = AuthenticationRepository.instance;
  //     final provider =
  //         auth.authUser!.providerData.map((e) => e.providerId).first;
  //     if (provider.isNotEmpty) {
  //       // Re verify Auth Email
  //       if (provider == 'google.com') {
  //         await auth.signInWithGoogle();
  //         await auth.deleteAccount();
  //         SgFullScreenLoader.stopLoading();
  //         Get.offAll(() => const LoginScreen());
  //       } else if (provider == 'password') {
  //         SgFullScreenLoader.stopLoading();
  //         Get.to(() => const ReAuthLoginForm());
  //       }
  //     }
  //   } catch (e) {
  //     SgFullScreenLoader.stopLoading();
  //     SgHelperFunctions.errorSnackBar(title: 'Oh Snap!', message: e.toString());
  //   }
  // }

  // /// RE_AUTHENTICATE before deleting
  // Future<void> reAuthenticateEmailAndPasswordUser() async {
  //   try {
  //     // Start Login
  //     SgFullScreenLoader.openLoadingDialog(
  //         'Processing', SgImages.docerAnimation);
  //
  //     // Check internet Connectivity
  //     final isConnected = await NetworkManager.instance.isConnected();
  //     if (!isConnected) {
  //       SgFullScreenLoader.stopLoading();
  //       return;
  //     }
  //
  //     // Form Validation
  //     if (!reAuthFormKey.currentState!.validate()) {
  //       SgFullScreenLoader.stopLoading();
  //       return;
  //     }
  //
  //     // ReAuthenticate user with email and password
  //     await AuthenticationRepository.instance
  //         .reAuthenticateWithEmailAndPassword(
  //             verifyEmail.text.trim(), verifyPassword.text.trim());
  //     await AuthenticationRepository.instance.deleteAccount();
  //
  //     // Stop Loading
  //     SgFullScreenLoader.stopLoading();
  //
  //     // Redirect
  //     Get.offAll(() => const LoginScreen());
  //   } catch (e) {
  //     SgFullScreenLoader.stopLoading();
  //     SgHelperFunctions.errorSnackBar(title: 'Oh Snap!', message: e.toString());
  //   }
  // }

  uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 512,
          maxHeight: 512);
      if (image != null) {
        // start loading
        imageUploading.value = true;
        // Upload Image
        final imageUrl =
            await userRepository.uploadImage('Users/Images/Profile/', image);

        // Update user Record
        Map<String, dynamic> json = {'profilepic': imageUrl};
        await userRepository.updateSingleField(json);

        // update Rx User
        user.value.profilePic = imageUrl;
        user.refresh();

        SgHelperFunctions.successSnackBar(
            title: 'Congratulations',
            message: 'Your Profile Image has been updated!');
      }
    } catch (e) {
      SgHelperFunctions.errorSnackBar(
          title: 'Oh Snap!', message: 'Something went wrong: $e');
    } finally {
      imageUploading.value = false;
    }
  }
}
