
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:gallery_saver/gallery_saver.dart';

late List<CameraDescription> _cameras;
double _scaleFactor = 1.0;
double _baseScaleFactor = 1.0;
FlashMode _flashMode = FlashMode.off;
GlobalKey key = GlobalKey();
AppBar appbar = AppBar();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
 runApp(const start());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {

    super.initState();
    //FlutterDisplayMode.setHighRefreshRate();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void test(factor) async{
    await controller.setZoomLevel(factor);
  }
  void flash() {
    if(_flashMode == FlashMode.off) {
      _flashMode = FlashMode.torch;
    } else {
      _flashMode = FlashMode.off;
    }
    controller.setFlashMode(_flashMode);
    //controller.setFocusPoint(Offset(Random().nextDouble(), Random().nextDouble()));
  }
  void image() async {
    XFile f = await controller.takePicture();
    File file = File(f.path);
    GallerySaver.saveImage(file.path, albumName: "PillerAI");
  }

  @override
  Widget build(BuildContext context) {

   // if (!controller.value.isInitialized) {
     // return Container();
    //}
    return Stack(
          children: [
            //MaterialApp(home: CameraPreview(controller),),
            Container(height: MediaQuery.of(context).size.height-appbar.preferredSize.height,child: CameraPreview(controller)),
             GestureDetector(
               key: key,
             onScaleStart: (details) {
         _baseScaleFactor = _scaleFactor;
         },
           onScaleUpdate: (details) {
             setState(() {
               _scaleFactor = _baseScaleFactor * details.scale;
               if(_scaleFactor < 1){
                 _scaleFactor = 1;
               } else if (_scaleFactor > 20){
                 _scaleFactor = 20;
               }
               test(_scaleFactor);

             });
           },
               onTapDown: (details){
               var box = key.currentContext?.findRenderObject() as RenderBox;
               controller.setFocusPoint(Offset(details.localPosition.dx/box.size.width,details.localPosition.dy/box.size.height));
               },
         ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: flash, child: Text("flash")),
                  ElevatedButton(onPressed: image, child: Text("Take Photo")),
                ],
              ),
            )
          ],
    );
  }
}
class start extends StatelessWidget {
  const start({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(appBar: appbar,body: const CameraApp(),));
  }
}
