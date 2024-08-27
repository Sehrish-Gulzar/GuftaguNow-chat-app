import 'package:chat_app_with_firebase/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(SgSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                SgTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: SgSizes.spaceBtwSections,
              ),

              /// Form
              const SgSignUpForm(),
            ],
          ),
        ),
      ),
    );
  }
}
