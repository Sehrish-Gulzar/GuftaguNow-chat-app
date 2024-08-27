import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../controller/CompleteProfileController.dart';

class CompleteProfile extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    final dark = SgHelperFunctions.isDarkMode(context);

    final controller =
        Get.put(CompleteProfileController(userModel, firebaseUser));

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: dark ? SgColors.light : SgColors.dark),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (controller.hasChanges()) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Unsaved Changes'),
                    content: const Text(
                        'You have unsaved changes. Do you want to save them?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context); // Go back without saving
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.uploadData(); // Save and go back
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Obx(() {
                return CupertinoButton(
                  onPressed: () => controller.showPhotoOptions(context),
                  padding: const EdgeInsets.all(0),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: (controller.imageFile.value != null)
                        ? FileImage(controller.imageFile.value!)
                        : (controller.userModel.profilePic != null &&
                                controller.userModel.profilePic!.isNotEmpty)
                            ? NetworkImage(controller.userModel.profilePic!)
                                as ImageProvider
                            : null,
                    child: (controller.imageFile.value == null &&
                            (controller.userModel.profilePic == null ||
                                controller.userModel.profilePic!.isEmpty))
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 20),
              TextField(
                controller: controller.fullNameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.uploadData(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text("Submit"),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
