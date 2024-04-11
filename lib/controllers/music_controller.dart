import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:external_path/external_path.dart';
import 'package:myrgb/controllers/record_controller.dart';
import 'package:myrgb/network/udp_connect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';

class MusicController extends GetxController {
  final recordController = Get.put(RecordController());
  final udpcontroller = Get.put(UDPController());
  final player = AudioPlayer();
  var files = <FileSystemEntity>[].obs;
  var currentlyPlayingIndex = (-1).obs;
  var isPlaying = false.obs;
  var currentPosition = 0.0.obs;
  var totalDuration = 0.0.obs;
  var sliderVal = 0.0.obs;
  Timer? _positionUpdateTimer;

  Timer? timer;
  double lastSentValue = 0;
  RecorderController? recorderController;

  void closeMusic() async {
    pauseSong();
    timer?.cancel();
    await recorderController?.stop();
    currentlyPlayingIndex = (-1).obs;
    isPlaying = false.obs;
    currentPosition = 0.0.obs;
    totalDuration = 0.0.obs;
    sliderVal = 0.0.obs;
  }

  Future<void> requestPermissionAndLoadFiles() async {
    var audioPerm = await Permission.audio.request();
    var recordPerm = await Permission.microphone.request();
    if (audioPerm.isGranted && recordPerm.isGranted) {
      getFiles();
    } else {
      audioPerm = await Permission.audio.request();
      recordPerm = await Permission.microphone.request();
    }
  }

  Future<void> getFiles() async {
    final externalPath = await ExternalPath.getExternalStorageDirectories();
    if (externalPath.isNotEmpty) {
      final directory = Directory('${externalPath[0]}/Music');
      final mp3Files =
          directory.listSync(recursive: true, followLinks: false).where((file) {
        return file.path.toLowerCase().endsWith('.mp3');
      }).toList();
      files.value = mp3Files;
    }
  }

  void playSong(int index) async {
    timer = Timer.periodic(
      Duration(milliseconds: 8),
      (Timer t) async {
        var db = await recordController.getDBvalue();
        double normalizedDb = recordController.normalise(db ?? 0);
        if (normalizedDb < recordController.minThreshold.value) {
          // Don't update colors if decibel value is below the threshold
          return;
        }
        double smoothedValue = recordController.smoothValue(
            recordController.mapNumber(normalizedDb, 0, 0.99, 0, 255));
        double offset = recordController.offset.value;
        if (smoothedValue.toInt() != lastSentValue) {
          lastSentValue = smoothedValue;
          double brightness = smoothedValue / 255;
          double redValue = (sin(brightness * pi * 2 + offset) + 1) / 2 * 255;
          double greenValue =
              (sin(brightness * pi * 2 + offset + pi / 3) + 1) / 2 * 255;
          double blueValue =
              (sin(brightness * pi * 2 + offset + 2 * pi / 3) + 1) / 2 * 255;
          offset += 0.01;
          udpcontroller.setParams(redValue.toInt(), greenValue.toInt(),
              blueValue.toInt(), smoothedValue.toInt(), 0);
        }
      },
    );
    if (player.playing) {
      await player.stop(); // Stop the currently playing song
      currentlyPlayingIndex.value = -1; // Reset the currentlyPlayingIndex
      isPlaying.value = false;
      sliderVal.value = 0.0; // Reset the slider value to zero
    }
    await player.setUrl(files[index].path);
    player.play();
    isPlaying.value = true;
    totalDuration.value = player.duration!.inMilliseconds.toDouble();
    currentlyPlayingIndex.value = index;

    // Listen for player state changes to detect when the song finishes
    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (index < files.length - 1) {
          playSong(index + 1);
        } else {
          playSong(0);
        }
      }
    });

  }

  void pauseSong() async {
    timer?.cancel();
    await recorderController?.stop();
    if (currentlyPlayingIndex.value == -1) {
      // If no song is playing, start playing the current song
      playSong(currentlyPlayingIndex.value);
      isPlaying.value = true;
    } else {
      if (player.playing) {
        player.pause();
        isPlaying.value = false;
      } else {
        player.play();
        isPlaying.value = true;
      }
    }
  }

  void seekToPosition(double position) {
    player.seek(Duration(milliseconds: position.toInt()));
    currentPosition.value = position;
  }

  void updatePosition() {
    sliderVal.value = player.position.inMilliseconds.toDouble();
  }

  @override
  void onInit() {
    super.onInit();
    requestPermissionAndLoadFiles();

    // Start a timer to update the position every 500 milliseconds
    _positionUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (isPlaying.value) {
        updatePosition();
      }
    });
  }

  @override
  void onClose() {
    // Cancel the timer when the controller is closed to prevent memory leaks
    _positionUpdateTimer?.cancel();
    super.onClose();
  }
}
