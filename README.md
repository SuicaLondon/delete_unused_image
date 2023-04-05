# Delete Unused Image 

With the growing size of a flutter project, it will have more and more images in the assets and most of them are not using. It is necessary to write a script to delete user content to reduce your project size. ~~Cut the time to find the image.~~

## TLDR How to use
It is the base version that needs to be refined to be used as a global library, the current document will only describe the parameter.

Delete all photo which is not referred at lib and the root folder. It will also detect the image name and remove its suffix to make a vague query.
```
flutter run bin/main 
```

If you only want to delete the image with the image suffix strictly.
```
flutter run bin/main --ignore-dynamic
or 
flutter run bin/main -i
```

You can also specify the path of root, lib and assets.
```
flutter run bin/main --root-path='./'
or
flutter run bin/main --root-path './'
or
flutter run bin/main --assets-path='./assets'
or
flutter run bin/main --assets-path './assets'
or
flutter run bin/main --lib-path='./lib'
or
flutter run bin/main --lib-path './lib'
or
```