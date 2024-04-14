import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

import 'package:myrgb/controllers/music_controller.dart';
import 'package:myrgb/controllers/record_controller.dart';
import 'package:myrgb/network/udp_connect.dart';
import 'package:myrgb/widgets/music_card.dart';
import 'package:myrgb/widgets/player.dart';
import 'package:get/get.dart';

class RecorderControllerWrapper extends GetxController {
  final RecorderController recorderController = RecorderController();
}

class Music extends StatelessWidget {
  final musicController = Get.put(MusicController());
  final recordController = Get.put(RecordController());
  final udpcontroller = Get.put(UDPController());
  Timer? timer;
  double lastSentValue = 0;

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
                            isPaused:
                                musicController.currentlyPlayingIndex.value ==
                                        index &&
                                    musicController.isPaused.value,
                            onCardTapped: () async {
                              await recorderController.record();

                              musicController.playSong(index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Player(musicController: musicController),
                ],
              );
            }
          },
        ));
  }
}
