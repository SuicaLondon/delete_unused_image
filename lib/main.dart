import 'dart:convert';
import 'dart:io';

import 'package:delete_unused_image/extension/file_extension.dart';
import 'package:delete_unused_image/file_reader.dart';
import 'package:delete_unused_image/image_modal.dart';
import 'package:delete_unused_image/utils/print.dart';

bool readArgument(List<String> arguments) {
  if (arguments.contains('ignore-dynamic')) {
    return true;
  }
  return false;
}

void main(List<String> arguments) async {
  FileReader fileReader = FileReader();
  final bool ignoreDynamicAssets = readArgument(arguments);
  final List<ImageEntityStatistics> imageEntities =
      await fileReader.readAssetsEntities();

  final List<FileSystemEntity> configureEntities =
      await fileReader.readRootFileEntity();
  final List<FileSystemEntity> libEntites =
      await fileReader.readLibFileEntity();

  RegExp numberRegex =
      RegExp(r'(\d+)(?=_|\@|\.)'); // Check xxx_1. xxx_1_xxx.png
  RegExp imageStringRegex =
      RegExp(r'''(?:'|").*\.(?:jpg|gif|png|webp)(?:'|")''');
  RegExp quoteRegex = RegExp('''(?:'|")''');
  String stringInterpolationPattern = r'\$(\w+|\{[^{}]+\})';

  fileReader.analyzeImages(
    ignoreDynamicAssets: ignoreDynamicAssets,
    imageEntities: imageEntities,
    configureEntities: configureEntities,
    libEntites: libEntites,
  );

  fileReader.deleteImage(imageEntities);
}
