import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:get/get_core/src/get_main.dart';
import 'package:myrgb/controllers/music_controller.dart';

class MusicCard extends StatelessWidget {
  final FileSystemEntity file;
  final bool isPlaying;
  final bool isPaused;
  final Function onCardTapped;

  MusicCard({
    required this.file,
    required this.isPlaying,
    required this.isPaused,
    required this.onCardTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: isPlaying ? 10 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPlaying
              ? Colors.cyan.withOpacity(0.5)
              : Colors.white.withOpacity(0.25),
          width: isPlaying ? 2.4 : 1,
        ),
      ),
      child: Container(
        child: GestureDetector(
          onTap: () {
            onCardTapped();
          },
          child: ListTile(
            title: Text(
              file.path.split('/').last.split(".").first,
              style: TextStyle(
                  color: isPaused
                      ? Colors.cyan.withOpacity(0.8)
                      : Colors.white.withOpacity(0.8)),
            ),
            leading: Icon(
              Icons.audiotrack,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
