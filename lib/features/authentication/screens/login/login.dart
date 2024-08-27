import 'package:chat_app_with_firebase/features/authentication/screens/login/widgets/login_form.dart';
import 'package:chat_app_with_firebase/features/authentication/screens/login/widgets/login_header.dart';
import 'package:flutter/material.dart';

import '../../../../common/styles/spacing_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: SgSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo , Title And Subtitle
              SgLoginHeader(),

              /// Form
              SgLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
