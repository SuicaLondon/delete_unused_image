import 'dart:convert';
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

extension DirectoryExtension on Directory {
  Future<List<FileSystemEntity>> getFileEntities(
      {bool recursive = false}) async {
    return (await Directory(path).list(recursive: recursive).toList())
        .whereType<File>()
        .where((entity) => !entity.name!.startsWith('.'))
        .toList();
  }
}

class ImageEntityStatistics {
  FileSystemEntity entity;
  int refered;

  ImageEntityStatistics({required this.entity, this.refered = 0});
}

void printSuccess(String text) {
  print('\x1B[32m$text\x1B[0m');
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

bool readArgument(List<String> arguments) {
  if (arguments.contains('ignore-dynamic')) {
    return true;
  }
  return false;
}

void main(List<String> arguments) async {
  final rootDir = Directory('./');
  final assetsDir = Directory('./assets');
  final libDir = Directory('./lib');
  final bool ignoreDynamicAssets = readArgument(arguments);
  final List<ImageEntityStatistics> imageEntities =
      (await assetsDir.getFileEntities(recursive: true))
          .map((entity) => ImageEntityStatistics(entity: entity, refered: 0))
          .toList();

  final List<FileSystemEntity> configureEntities =
      await rootDir.getFileEntities();
  final List<FileSystemEntity> libEntites =
      await libDir.getFileEntities(recursive: true);

  RegExp numberRegex =
      RegExp(r'(\d+)(?=_|\@|\.)'); // Check xxx_1. xxx_1_xxx.png
  RegExp imageStringRegex =
      RegExp(r'''(?:'|").*\.(?:jpg|gif|png|webp)(?:'|")''');
  RegExp quoteRegex = RegExp('''(?:'|")''');
  String stringInterpolationPattern = r'\$(\w+|\{[^{}]+\})';

  [...configureEntities, ...libEntites].forEach((codeEntity) {
    if (codeEntity is File) {
      String fileString = codeEntity.readAsStringSync();
      for (var imageEntity in imageEntities) {
        String? imageName = imageEntity.entity.name;
        String? imageFileName = imageEntity.entity.fileName;
        String? extensionName = imageEntity.entity.ext;
        if (imageName != null) {
          if (fileString.contains(imageName)) {
            imageEntity.refered++;
          } else if (imageFileName != null &&
              fileString.contains(imageFileName)) {
            // Some file seperate the file with it file fomat
            imageEntity.refered++;
          } else if (!ignoreDynamicAssets) {
            // For the image like account_vip$vipLvl.webp
            if (numberRegex.hasMatch(imageName)) {
              // If the path of image container number
              String replacedPattern = imageName.splitMapJoin(numberRegex,
                  onMatch: (s) => stringInterpolationPattern);

              RegExp imagePathRegex = RegExp(replacedPattern);
              if (imagePathRegex.hasMatch(fileString)) {
                imageEntity.refered++;
              }
            } else if (extensionName != null &&
                imageFileName != null &&
                fileString.contains(extensionName)) {
              // "nav_arrow_${show ? 'up' : 'down'}.webp"
              var lines = imageStringRegex.allMatches(fileString);
              for (var line in lines) {
                var imgPath = line[0];
                if (imgPath != null && imgPath.contains(extensionName)) {
                  RegExp fuzzyRegex = RegExp(stringInterpolationPattern);
                  imgPath = imgPath.replaceAll(quoteRegex, '');
                  List<String> splitStrings = imgPath.split(fuzzyRegex);
                  if (splitStrings.every((str) => imageName.contains(str))) {
                    imageEntity.refered++;
                  }
                }
              }
            }
          }
        } else {
          printError('Name not exists: ${imageEntity.entity.name}');
        }
      }
    }
  });
  imageEntities.sort((a, b) => b.refered.compareTo(a.refered));
  List<Future<FileSystemEntity>> deleteList = [];
  for (var imageEntity in imageEntities) {
    if (imageEntity.refered > 0) {
      printSuccess(
          '${imageEntity.entity.path} ----- refered ${imageEntity.refered}');
    } else {
      deleteList.add(imageEntity.entity.delete().then((value) {
        printWarning('${imageEntity.entity.path} unsed ----- deleted');
        return value;
      }).catchError((error) {
        printError('Deleted ${imageEntity.entity.path} failed. Error: $error');
        throw error;
      }));
    }
  }
  if (deleteList.length > 0) {
    Future.wait(deleteList).then((value) {
      printWarning('Deleted all unsed assets completed');
    }).catchError((error) {
      printError('Was unable to delete some of the assets');
    });
  } else {
    printSuccess('Congragulation! Nothing to delete');
  }
}
