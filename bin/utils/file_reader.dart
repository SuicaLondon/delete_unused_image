import 'dart:io';

import '../extension/file_extension.dart';
import '../model/image_model.dart';
import '../extension/directory_extension.dart';
import 'print.dart';
import 'regex.dart';

class FileReader {
  late final String rootPath;
  late final String assetsPath;
  late final String libPath;
  Directory get rootDir {
    return Directory(rootPath);
  }

  Directory get assetsDir {
    return Directory(assetsPath);
  }

  Directory get libDir {
    return Directory(libPath);
  }

  FileReader({
    this.rootPath = './',
    this.assetsPath = './assets',
    this.libPath = './lib',
  });

  Future<List<ImageEntityStatistics>> readAssetsEntities() async {
    return (await assetsDir.getFileEntities(recursive: true))
        .map((entity) => ImageEntityStatistics(entity: entity, referred: 0))
        .toList();
  }

  Future<List<FileSystemEntity>> readRootFileEntity() async {
    return rootDir.getFileEntities();
  }

  Future<List<FileSystemEntity>> readLibFileEntity() async {
    return libDir.getFileEntities(recursive: true);
  }

  List<ImageEntityStatistics> analyzeImages({
    bool ignoreDynamicAssets = false,
    required List<ImageEntityStatistics> imageEntities,
    required List<FileSystemEntity> configureEntities,
    required List<FileSystemEntity> libEntites,
  }) {
    for (var codeEntity in [...configureEntities, ...libEntites]) {
      if (codeEntity is File) {
        String fileString = codeEntity.readAsStringSync();
        for (var imageEntity in imageEntities) {
          String? imageName = imageEntity.entity.name;
          String? imageFileName = imageEntity.entity.fileName;
          String? extensionName = imageEntity.entity.ext;
          if (imageName != null) {
            if (fileString.contains(imageName)) {
              imageEntity.referred++;
            } else if (imageFileName != null &&
                fileString.contains(imageFileName)) {
              // Some file seperate the file with it file fomat
              imageEntity.referred++;
            } else if (!ignoreDynamicAssets) {
              // For the image like account_vip$vipLvl.webp
              if (numberRegex.hasMatch(imageName)) {
                // If the path of image container number
                String replacedPattern = imageName.splitMapJoin(numberRegex,
                    onMatch: (s) => stringInterpolationPattern);

                RegExp imagePathRegex = RegExp(replacedPattern);
                if (imagePathRegex.hasMatch(fileString)) {
                  imageEntity.referred++;
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
                      imageEntity.referred++;
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
    }
    imageEntities.sort((a, b) => b.referred.compareTo(a.referred));
    return imageEntities;
  }

  void deleteImage(List<ImageEntityStatistics> imageEntities) {
    List<Future<FileSystemEntity>> deleteList = [];
    for (var imageEntity in imageEntities) {
      if (imageEntity.referred > 0) {
        printSuccess(
            '${imageEntity.entity.path} ----- refered ${imageEntity.referred}');
      } else {
        deleteList.add(imageEntity.entity.delete().then((value) {
          printWarning('${imageEntity.entity.path} unsed ----- deleted');
          return value;
        }).catchError((error) {
          printError(
              'Deleted ${imageEntity.entity.path} failed. Error: $error');
          throw error;
        }));
      }
    }
    if (deleteList.isNotEmpty) {
      Future.wait(deleteList).then((value) {
        printWarning('Deleted all unsed assets completed');
      }).catchError((error) {
        printError('Was unable to delete some of the assets');
      });
    } else {
      printSuccess('Congragulation! Nothing to delete');
    }
  }
}
