import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';

/// ImageUtils
class ImageUtils {
  static Uint8List imageToByteListUint8(imageLib.Image image) {
    var width = image.width;
    var height = image.height;
    var convertedBytes = Uint8List(width * height * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        var pixel = image.getPixel(i, j);
        int red = pixel.r.toInt(); // Red 채널 추출
        int green = pixel.g.toInt(); // Green 채널 추출
        int blue = pixel.b.toInt(); // Blue 채널 추출

        buffer[pixelIndex++] = red;
        buffer[pixelIndex++] = green;
        buffer[pixelIndex++] = blue;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /// Converts a [CameraImage] in YUV420 format to [imageLib.Image] in RGB format
  static imageLib.Image? convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      return null;
    }
  }

  /// Converts a [CameraImage] in BGRA888 format to [imageLib.Image] in RGB format
  static imageLib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    const int numChannels = 4; // BGRA는 4개의 채널을 가짐
    // 새로운 Image.fromBytes 사용법에 맞게 수정
    ByteBuffer buffer = cameraImage.planes[0].bytes.buffer;

    imageLib.Image img = imageLib.Image.fromBytes(
      width: width,
      height: height,
      bytes: buffer,
      format: imageLib.Format.uint8, // uint8 포맷 사용
      numChannels: numChannels,
      order: imageLib.ChannelOrder.bgra, // BGRA 순서 사용
    );

    return img;
  }

  /// Converts a [CameraImage] in YUV420 format to [imageLib.Image] in RGB format
  static imageLib.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    // Image 인스턴스를 생성할 때, 명시적 파라미터를 전달합니다.
    final image = imageLib.Image(
      width: width,
      height: height,
      numChannels: 3,
    );

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.setPixelRgb(w, h, y, u, v);
      }
    }
    return image;
  }

  /// Convert a single YUV pixel to RGB
  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    int r = (y + v * 1436 / 1024 - 179).round();
    int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    int b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  static int imageIndex = 0; // 전역 변수를 설정하여 고유 인덱스를 생성

  static void saveImage(imageLib.Image image) async {
    List<int> jpeg = imageLib.encodeJpg(image); // 이미지를 JPEG로 인코딩
    final appDir = await getTemporaryDirectory();
    final appPath = appDir.path;
    final fileOnDevice =
        File('$appPath/out$imageIndex.jpg'); // 파일 이름에 고유 인덱스 사용
    await fileOnDevice.writeAsBytes(jpeg, flush: true);
    print('Saved $appPath/out$imageIndex.jpg');
    imageIndex++; // 파일을 저장할 때마다 인덱스를 증가
  }
}
