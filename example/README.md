# Delete Unused Image 

With the growing size of a flutter project, it will have more and more images in the assets and most of them are not used. It is necessary to write a script to delete user content to reduce your project size. ~~Cut the time to find the image.~~

## Install
```
dart pub global activate delete_unused_image
```

## TLDR How to use
It is the base version that needs to be refined to be used as a global library, the current document will only describe the parameter.

Delete all photos which are not referred to in lib and the root folder. It will also detect the image name and remove its suffix to make a vague query.
```
dart pub global run delete_unused_image
```

If you only want to delete the image with the image suffix strictly.
```
dart pub global run delete_unused_image --ignore-dynamic
or 
dart pub global run delete_unused_image -i
```

You can also specify the path of root, lib and assets.
```
dart pub global run delete_unused_image --root-path='./'
or
dart pub global run delete_unused_image --root-path './'
or
dart pub global run delete_unused_image --assets-path='./assets'
or
dart pub global run delete_unused_image --assets-path './assets'
or
dart pub global run delete_unused_image --lib-path='./lib'
or
dart pub global run delete_unused_image --lib-path './lib'
or
```