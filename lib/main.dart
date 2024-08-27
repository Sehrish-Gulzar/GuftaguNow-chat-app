import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'data/services/firebase_storage_services.dart';
import 'firebase_options.dart';

var uuid = const Uuid();

void main() async {
  /// Widgets Binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// Await Native Splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));
  Get.put(SgFirebaseStorageService());
  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const MyApp());
}
