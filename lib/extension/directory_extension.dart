import 'dart:io';

import 'package:delete_unused_image/extension/file_extension.dart';

extension DirectoryExtension on Directory {
  Future<List<FileSystemEntity>> getFileEntities(
      {bool recursive = false}) async {
    return (await Directory(path).list(recursive: recursive).toList())
        .whereType<File>()
        .where((entity) => !entity.name!.startsWith('.'))
        .toList();
  }
}
