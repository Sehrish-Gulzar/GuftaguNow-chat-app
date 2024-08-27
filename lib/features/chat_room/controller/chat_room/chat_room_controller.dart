import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data/repositories/chat_room/chat_room_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/models/user_model.dart';
import '../../models/chat_rooms.dart';

class ChatRoomController extends GetxController {
  final ChatRoomRepository repository;
  ChatRoomController(this.repository);

  ///  Audio Recorder Variables
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final RxBool _isRecording = false.obs;
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxMap<String, Duration> duration = <String, Duration>{}.obs;
  final RxMap<String, Duration> position = <String, Duration>{}.obs;
  final RxMap<String, bool> isPlaying = <String, bool>{}.obs;
  final RxMap<String, bool> isPause = <String, bool>{}.obs;
  final RxMap<String, bool> isAudioLoading = <String, bool>{}.obs;
  String? currentlyPlayingAudioId;

  final RxBool isLoading = false.obs;
  final RxBool emojiShowing = false.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final UserRepository userRepository = Get.put(UserRepository());

  /// Request permission then it Initialized Recorder
  @override
  void onInit() {
    super.onInit();
    requestPermissions().then((_) {
      initializeRecorder();
    });
  }

  @override
  void onClose() {
    _recorder.closeRecorder();
    super.onClose();
  }

  /// Initialize/Open Recorder
  Future<void> initializeRecorder() async {
    await _recorder.openRecorder();
  }

  /// Request Permission for microphone and storage
  Future<void> requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  /// Change duration value
  void changeSeek(double value) {
    audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  /// Play Audio
  void playAudio(String audioUrl, String audioId) async {
    try {
      // If another audio is currently playing, stop it and reset its state
      if (currentlyPlayingAudioId != null &&
          currentlyPlayingAudioId != audioId) {
        await audioPlayer.stop();
        isPlaying[currentlyPlayingAudioId!] = false;
        isPause[currentlyPlayingAudioId!] = false;
        duration[currentlyPlayingAudioId!] = const Duration();
        position[currentlyPlayingAudioId!] = const Duration();
        currentlyPlayingAudioId = null;
      }

      // Play, pause, or resume the audio
      if (isPause[audioId] ?? false) {
        await audioPlayer.resume();
        isPlaying[audioId] = true;
        isPause[audioId] = false;
      } else if (isPlaying[audioId] ?? false) {
        await audioPlayer.pause();
        isPlaying[audioId] = false;
        isPause[audioId] = true;
      } else {
        isAudioLoading[audioId] = true;
        await audioPlayer.play(UrlSource(audioUrl));
        isPlaying[audioId] = true;
        isPause[audioId] = false;
        currentlyPlayingAudioId = audioId;

        audioPlayer.onDurationChanged.listen((Duration d) {
          duration[audioId] = d;
          isAudioLoading[audioId] = false;
        });

        audioPlayer.onPositionChanged.listen((Duration p) {
          position[audioId] = p;
        });

        audioPlayer.onPlayerComplete.listen((event) {
          isPlaying[audioId] = false;
          duration[audioId] = const Duration();
          position[audioId] = const Duration();
          currentlyPlayingAudioId = null;
        });
      }

      // Log the state for debugging
      log('Playing audio: $audioId, isPlaying: ${isPlaying[audioId]}, isPause: ${isPause[audioId]}, duration: ${duration[audioId]}');
    } catch (e) {
      log('Error in playAudio: $e');
    }
  }

  /// Start Recording
  Future<void> startRecording() async {
    try {
      if (!_isRecording.value) {
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/temp.aac';

        PermissionStatus microphoneStatus = await Permission.microphone.status;
        PermissionStatus storageStatus = await Permission.storage.status;

        if (!microphoneStatus.isGranted || !storageStatus.isGranted) {
          await requestPermissions();

          microphoneStatus = await Permission.microphone.status;
          storageStatus = await Permission.storage.status;

          if (!microphoneStatus.isGranted || !storageStatus.isGranted) {
            SgHelperFunctions.errorSnackBar(
              title: 'Permission Denied',
              message: 'Recording and storage permissions are required.',
            );
            return;
          }
        }

        await _recorder.startRecorder(
          toFile: tempPath,
          codec: Codec.aacADTS,
        );

        _isRecording.value = true;
        log('Recording started');
        messageController.text = "Recording Started";
      }
    } catch (e) {
      print('Error in startRecording: $e');
      SgHelperFunctions.errorSnackBar(
        title: 'Recording Error',
        message: 'Failed to start recording: $e',
      );
    }
  }

  /// Stop Recording
  Future<void> stopRecording(
      UserModel userModel, ChatRoomModel chatroom, UserModel targetUser) async {
    try {
      if (_isRecording.value) {
        String? audioPath = await _recorder.stopRecorder();
        _isRecording.value = false;
        messageController.clear();
        log('Recording stopped, file saved at $audioPath');

        if (audioPath != null) {
          File audioFile = File(audioPath);
          String audioUrl = await uploadFile('Message/Audios/', audioFile);

          // Calculate the actual duration of the audio file
          final audioFileDuration = await _getAudioDuration(audioFile);

          if (audioUrl.isNotEmpty) {
            sendMessage(
              userModel,
              chatroom,
              targetUser,
              audioUrl: audioUrl,
              audioDuration: audioFileDuration.inSeconds,
            );
          }
        }
      }
    } catch (e) {
      log('Error in stopRecording: $e');
      SgHelperFunctions.errorSnackBar(
        title: 'Recording Error',
        message: 'Failed to stop recording: $e',
      );
    }
  }

  // Get audio duration
  Future<Duration> _getAudioDuration(File audioFile) async {
    final player = AudioPlayer();
    final completer = Completer<Duration>();

    player.setSourceUrl(audioFile.uri.toString());
    player.onDurationChanged.listen((Duration d) {
      completer.complete(d);
    });

    return completer.future;
  }

  /// Upload image file
  Future<String> uploadFile(String path, File file) async {
    try {
      String fileUrl = await repository.uploadFile(path, file);
      return fileUrl;
    } catch (e) {
      SgHelperFunctions.errorSnackBar(
        title: 'Oh Snap!',
        message: 'Something went wrong: $e',
      );
      return '';
    }
  }

  /// Pick image from gallery
  void selectImage(
      UserModel userModel, ChatRoomModel chatroom, UserModel targetUser,
      {context}) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageUrl =
          await uploadFile('Message/Images/', File(pickedFile.path));
      if (imageUrl.isNotEmpty) {
        sendMessage(
          userModel,
          chatroom,
          targetUser,
          imageUrl: imageUrl,
        );
      }
    }
  }

  /// Send message
  void sendMessage(
    UserModel userModel,
    ChatRoomModel chatroom,
    UserModel targetUser, {
    String? message,
    String? imageUrl,
    String? audioUrl,
    int? audioDuration,
  }) async {
    isLoading.value = true;
    messageController.clear();
    emojiShowing.value = false;

    try {
      await repository.sendMessage(
        userModel,
        chatroom,
        targetUser,
        message ?? '',
        imageUrl ?? '',
        audioUrl ?? '',
        audioDuration ?? 0,
      );
    } catch (e) {
      SgHelperFunctions.errorSnackBar(
        title: 'Error',
        message: 'Failed to send message: $e',
      );
    }

    isLoading.value = false;
  }

  /// Get messages
  Stream<QuerySnapshot> getMessages(String chatroomId) {
    return repository.getMessages(chatroomId);
  }

  /// Toggle emoji picker
  void toggleEmojiPicker() {
    emojiShowing.value = !emojiShowing.value;
  }
}
