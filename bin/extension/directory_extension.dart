import 'dart:io';

import 'file_extension.dart';

extension DirectoryExtension on Directory {
  Future<List<FileSystemEntity>> getFileEntities(
      {bool recursive = false}) async {
    return (await Directory(path).list(recursive: recursive).toList())
        .whereType<File>()
        .where((entity) => !entity.name!.startsWith('.'))
        .toList();
  }
}
