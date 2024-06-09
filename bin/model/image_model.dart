import 'dart:io';

class ImageEntityStatistics {
  final FileSystemEntity entity;
  int referred;

  ImageEntityStatistics({
    required this.entity,
    this.referred = 0,
  });
}
