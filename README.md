# WNPlayer
WNPlayer万能播放器，使用FFmpeg最新版本(4.0.2)，没有使用FFmpeg的废弃api，支持几乎所有视频格式(avi、flv、m3u8、3gp、RTMP、RTSP、MKV、rmvb、wmv、mp4、mov)，网络和本地视频同时支持；支持自定义控制层。


使用注意事项

1、先下载FFmpeg的编译文件，可以去到我的网盘下载（FFmpeg的版本是4.0.2,如果自己会编译，也可以自行编译），如果过期及时联系本人，微信18824905363


复制这段内容后打开百度网盘手机App，操作更方便哦
链接：https://pan.baidu.com/s/1h5p9HJ3eaLQi-O6tk6tu2A 提取码：N6A8


2、第一步的下载文件，提取lib文件夹里面的.a文件，放到项目中的FFmpeg文件下面的lib文件目录下面

3、去项目系统Setting里面

    3.1、设置Header Search Paths为 "$(SRCROOT)/WNPlayer/FFmpeg/include"

    3.2、设置Library Search Paths为 $(PROJECT_DIR)/WNPlayer/FFmpeg/lib
    
         $(PROJECT_DIR)/WNPlayer/WNPlayer/openssl/lib

4、添加iOS系统的依赖库

MediaPlayer.framework
AudioToolBox.framework
VideoToolBox.framework
OpenGLES.framework
libiconv.tbd
libbz2.tbd
libz.tbd
