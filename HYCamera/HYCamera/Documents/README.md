#  慧眼摄像头集成指导

1、Build Settings 里，把 `Compile Sources As`  设为 `Objective-C++`；
2、Build Settings 里，在`Other C Flags`里添加三个标志：`-DLINUX`、`-DLINUX_iOS`、`-DLINUX_iOS_64`



### 错误处理：
1、如果跑项目报 `Image not found` 的错误，需要在主工程的 Embedded Binaries 里添加 `HYCamera.framework`
参见：https://stackoverflow.com/questions/24993752/os-x-framework-library-not-loaded-image-not-found
