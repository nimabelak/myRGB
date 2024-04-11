import 'package:flutter/material.dart';
import 'dart:io';


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