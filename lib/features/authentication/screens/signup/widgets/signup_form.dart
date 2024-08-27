import 'package:chat_app_with_firebase/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/signup/signup_controller.dart';

class SgSignUpForm extends StatelessWidget {
  const SgSignUpForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.fullName,
            validator: (value) => SgValidator.validateEmptyText('Name', value),
            expands: false,
            decoration: const InputDecoration(
                labelText: SgTexts.Name, prefixIcon: Icon(Iconsax.user)),
          ),
          const SizedBox(
            height: SgSizes.spaceBtwInputFields,
          ),

          /// Email
          TextFormField(
            controller: controller.email,
            validator: (value) => SgValidator.validateEmail(value),
            decoration: const InputDecoration(
                labelText: SgTexts.email, prefixIcon: Icon(Iconsax.direct)),
          ),
          const SizedBox(
            height: SgSizes.spaceBtwInputFields,
          ),

          /// Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => SgValidator.validatePassword(value),
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: SgTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value,
                  icon: Icon(controller.hidePassword.value
                      ? Iconsax.eye_slash
                      : Iconsax.eye),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: SgSizes.spaceBtwSections,
          ),

          /// Terms&Conditions Checkbox
          const SgTermsAndConditionCheckbox(),
          const SizedBox(
            height: SgSizes.spaceBtwSections,
          ),

          /// SignUp Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => controller.signup(),
                  child: const Text(SgTexts.createAccount))),
          const SizedBox(
            height: SgSizes.spaceBtwSections,
          ),
        ],
      ),
    );
  }
}
