import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:SmartPoopoo/common_widgets.dart';

class ImageDetectionScreen extends StatefulWidget {
  const ImageDetectionScreen({super.key});

  @override
  State<ImageDetectionScreen> createState() => _ImageDetectionScreenState();
}

Future<List<String>> loadLabels(String labelPath) async {
  String labelsData = await rootBundle.loadString(labelPath);
  return labelsData.split('\n'); // 레이블이 각 줄에 하나씩 있다고 가정
}

class _ImageDetectionScreenState extends State<ImageDetectionScreen> {
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];
  bool firststate = false;
  bool message = true;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  Future<void> initStateAsync() async {
    List<String> labels = await loadLabels("assets/labels/labels_diaper.txt");

    _objectModel = ModelObjectDetection(
        0, // index
        640, // image width
        640, // image height
        labels, // 레이블 리스트
        modelType: ObjectDetectionModelType.yolov5 // 모델 타입 설정
        );
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/best.pt";
    try {
      _objectModel = await PytorchLite.loadObjectDetectionModel(
          // change the 80 with number of classes in your model pretrained yolov5 had almost 80 classes so I added 80 here.
          pathObjectDetectionModel,
          80,
          640,
          640,
          labelPath: "assets/labels/labels_diaper.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  void handleTimeout() {
    // callback function
    // Do some work.
    setState(() {
      firststate = true;
    });
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  //running detections on image
  Future runObjectDetection() async {
    setState(() {
      firststate = false;
      message = false;
    });
    //pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      objDetect = await _objectModel.getImagePrediction(
        await image.readAsBytes(),
      );
    } else {
      print("이미지를 선택하지 않았습니다.");
    }

    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        iOUThreshold: 0.3);
    for (var element in objDetect) {
      print(
        {
          "score": element?.score,
          "className": element?.className,
          "class": element?.classIndex,
          "rect": {
            "left": element?.rect.left,
            "top": element?.rect.top,
            "width": element?.rect.width,
            "height": element?.rect.height,
            "right": element?.rect.right,
            "bottom": element?.rect.bottom,
          },
        },
      );
    }
    scheduleTimeout(5 * 1000);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OBJECT DETECTOR APP")),
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Image with Detections....

          !firststate
              ? !message
                  ? const LoaderState()
                  : const Text("Select the Camera to Begin Detections")
              : Expanded(
                  child: Container(
                      child:
                          _objectModel.renderBoxesOnImage(_image!, objDetect)),
                ),

          // !firststate
          //     ? LoaderState()
          //     : Expanded(
          //         child: Container(
          //             height: 150,
          //             width: 300,
          //             child: objDetect.isEmpty
          //                 ? Text("hello")
          //                 : _objectModel.renderBoxesOnImage(
          //                     _image!, objDetect)),
          //       ),
          Center(
            child: Visibility(
              visible: _imagePrediction != null,
              child: Text("$_imagePrediction"),
            ),
          ),
          //Button to click pic
          ElevatedButton(
            onPressed: () {
              runObjectDetection();
            },
            child: const Icon(Icons.camera),
          )
        ],
      )),
    );
  }
}
