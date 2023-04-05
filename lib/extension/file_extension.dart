import 'dart:io';

extension FileExtention on FileSystemEntity {
  String? get name {
    return path.split("/").last;
  }

  String? get fileName {
    return path.split("/").last.split('.').first;
  }

  String? get ext {
    return path.split("/").last.split('.').last;
  }
}
