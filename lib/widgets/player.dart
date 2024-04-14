import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:myrgb/Pages/music.dart';
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
      padding: const EdgeInsets.only(bottom: 58),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                // Play the previous song
                int currentIndex = musicController.currentlyPlayingIndex.value;
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
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  musicController.pauseSong();
                  musicController.isPaused.value =
                      !musicController.isPaused.value;
                },
                child: Icon(
                  musicController.isPlaying.value
                      ? Icons.pause
                      : Icons.play_arrow_rounded,
                  color: Colors.cyan[100]?.withOpacity(0.8),
                  size: 40,
                ),
              );
            }),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                // Play the next song
                int currentIndex = musicController.currentlyPlayingIndex.value;
                if (currentIndex < musicController.files.length - 1) {
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
                  activeColor: Colors.cyan[100]?.withOpacity(0.8),
                  inactiveColor: Colors.white.withOpacity(0.25),
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
