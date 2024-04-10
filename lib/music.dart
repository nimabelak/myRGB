import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import 'package:just_audio/just_audio.dart' show PlayingAudioSource;

class MusicController extends GetxController {
  final player = AudioPlayer();
  var files = <FileSystemEntity>[].obs;
  var currentlyPlayingIndex = (-1).obs;
  var isPlaying = false.obs;
  var currentPosition = 0.0.obs;
  var totalDuration = 0.0.obs;
  var sliderVal = 0.0.obs;
  Timer? _positionUpdateTimer;

  void closeMusic() {
    pauseSong();
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
    //print the song's realtime amplitude
  }

  void pauseSong() {
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

class Music extends StatelessWidget {
  final MusicController musicController = Get.put(MusicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 20, 43, 66),
          title: Text("Music"),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 43, 66),
        body: Obx(
          () {
            if (musicController.files.isEmpty) {
              return InkWell(
                onTap: () {
                  musicController.requestPermissionAndLoadFiles();
                },
                child: const Center(child: Text("No Songs Found!")),
              );
            } else {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: musicController.files.length,
                      itemBuilder: (context, index) {
                        return Obx(
                          () => MusicCard(
                            file: musicController.files[index],
                            isPlaying:
                                musicController.currentlyPlayingIndex.value ==
                                        index &&
                                    musicController.isPlaying.value,
                            onCardTapped: () {
                              musicController.playSong(index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromARGB(255, 230, 143, 117),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              // Play the next song
                              int currentIndex =
                                  musicController.currentlyPlayingIndex.value;
                              if (currentIndex > 0) {
                                musicController.playSong(currentIndex - 1);
                              }
                            },
                            child: const Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Obx(() {
                            return InkWell(
                              onTap: () {
                                musicController.pauseSong();
                              },
                              child: Icon(
                                musicController.isPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          }),
                          InkWell(
                            onTap: () {
                              // Play the next song
                              int currentIndex =
                                  musicController.currentlyPlayingIndex.value;
                              if (currentIndex <
                                  musicController.files.length - 1) {
                                musicController.playSong(currentIndex + 1);
                              }
                            },
                            child: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Container(
                            width: 200,
                            child: Obx(() {
                              return Slider(
                                activeColor: Colors.deepOrange,
                                inactiveColor:
                                    Color.fromARGB(255, 255, 203, 187),
                                value: musicController.sliderVal.value,
                                min: 0.0,
                                max: musicController.totalDuration.value,
                                onChanged: (value) {
                                  musicController.seekToPosition(value);
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ));
  }
}

class MusicCard extends StatelessWidget {
  final FileSystemEntity file;
  final bool isPlaying;
  final Function onCardTapped;

  MusicCard({
    required this.file,
    required this.isPlaying,
    required this.onCardTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isPlaying ? Colors.white70 : Colors.white,
      child: ListTile(
        title: Text(file.path.split('/').last.split(".").first),
        leading: const Icon(Icons.audiotrack),
        trailing: isPlaying
            ? const Icon(Icons.pause, color: Colors.redAccent)
            : const Icon(Icons.play_arrow_rounded, color: Colors.redAccent),
        onTap: () {
          onCardTapped();
        },
      ),
    );
  }
}
