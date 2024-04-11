import 'package:flutter/material.dart';
import 'package:myrgb/controllers/music_controller.dart';
import 'package:get/get.dart';


class Player extends StatelessWidget {
  const Player({
    super.key,
    required this.musicController,
  });

  final MusicController musicController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
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
    );
  }
}