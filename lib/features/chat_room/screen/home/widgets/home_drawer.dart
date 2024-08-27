import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../../authentication/screens/login/login.dart';
import '../../profile/complete_profile.dart';

class HomeDrawer extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomeDrawer({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    final dark = SgHelperFunctions.isDarkMode(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: SgColors.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: userModel.profilePic != null &&
                          userModel.profilePic!.isNotEmpty
                      ? NetworkImage(userModel.profilePic!)
                      : null,
                  child: ((userModel.profilePic == null ||
                          userModel.profilePic!.isEmpty))
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return CompleteProfile(
                            userModel: userModel, firebaseUser: firebaseUser);
                      }),
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    color: dark ? SgColors.white : SgColors.dark,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Center(
              child: Text(
                userModel.fullName ?? 'no name ',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            subtitle: Center(
                child: Text(
              userModel.email ?? 'no email',
              style: Theme.of(context).textTheme.bodyMedium,
            )),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await AuthenticationRepository.instance.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const LoginScreen();
                      }),
                    );
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: dark ? SgColors.white : SgColors.dark,
                  ),
                ),
                Text(
                  "Sign Out",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
