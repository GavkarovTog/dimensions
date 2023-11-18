import 'dart:io';

import 'package:dimensions/figure_painter.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:dimensions/utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Figure? figure;
  Camera camera = Camera(Vertex4(0, 0, 6.0));

  bool rotation = false;
  bool scale = false;
  bool offset = false;

  double scaleX = 1.0;
  double scaleY = 1.0;
  double scaleZ = 1.0;

  double rotationX = 0;
  double rotationY = 0;
  double rotationZ = 0;

  double offsetX = 0;
  double offsetY = 0;
  double offsetZ = 0;

  int mirrorX = 0;
  int mirrorY = 0;
  int mirrorZ = 0;

  List<TransformationCommand> rotations = [];
  List<TransformationCommand> scales = [];
  List<TransformationCommand> offsets = [];

  Widget _createButton(Widget child, void Function()? action) {
    return InkWell(
        onTap: action,
        splashColor: Colors.orangeAccent,
        child: Ink(
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: child));
  }

  Widget _createFileLoadBanner(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
              text: TextSpan(
                  text: "Загрузите ",
                  style: TextStyle(color: Colors.black, fontSize: 32),
                  children: [
                    TextSpan(
                        text: "3D-объект",
                        style: TextStyle(color: Colors.blueAccent))
                  ]),
              textAlign: TextAlign.center),
          SizedBox(height: 40),
          Center(
            child: InkWell(
              onTap: () async {
                FilePickerResult? loadedFiles =
                    await FilePicker.platform.pickFiles();

                if (loadedFiles != null) {
                  if (loadedFiles.names.first!.split('.').last != "obj") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Вы должны загрузить файла формата '.obj'")));
                  } else {
                    File file = File(loadedFiles.files.single.path!);

                    setState(() {
                      figure = Figure3D.parse(file.readAsStringSync());
                    });
                  }
                }
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blueAccent,
                ),
                width: 200,
                height: 200,
                child: Icon(Icons.file_present, color: Colors.white, size: 192),
              ),
            ),
          )
        ],
      ),
    ]);
  }

  Widget _createObserver3D(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Ink(
            color: Colors.orange,
            child: Row(
              children: [
                _createButton(Text("Вращение"), () {
                  rotation = true;
                  scale = false;
                  offset = false;
                }),
                _createButton(Text("Масштабирование"), () {
                  rotation = false;
                  scale = true;
                  offset = false;
                }),
                _createButton(Text("Смещение"), () {
                  rotation = false;
                  scale = false;
                  offset = true;
                }),
                _createButton(Text("Зеркало X"), () {
                  mirrorX = mirrorX ^ 1;
                  setState(() {});
                }),
                _createButton(Text("Зеркало Y"), () {
                  mirrorY = mirrorY ^ 1;
                  setState(() {});
                }),
                _createButton(Text("Зеркало Z"), () {
                  mirrorZ = mirrorZ ^ 1;
                  setState(() {});
                }),
                _createButton(Text("Сброс"), () {
                  rotation = false;
                  scale = false;
                  offset = false;

                  scaleX = 1.0;
                  scaleY = 1.0;
                  scaleZ = 1.0;

                  rotationX = 0;
                  rotationY = 0;
                  rotationZ = 0;

                  offsetX = 0;
                  offsetY = 0;
                  offsetZ = 0;

                  mirrorX = 0;
                  mirrorY = 0;
                  mirrorZ = 0;

                  setState(() {});
                }),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(children: [
            ClipRect(
              clipBehavior: Clip.hardEdge,
              child: CustomPaint(
                foregroundPainter:
                    FigurePainter(figure!,
                        [RotationCommand(rotationX, rotationY, rotationZ)],
                        [ScaleCommand(scaleX, scaleY, scaleZ)],
                        [OffsetCommand(offsetX, offsetY, offsetZ)],
                        [MirrorCommand(mirrorX.toDouble(), mirrorY.toDouble(), mirrorZ.toDouble())],
                        camera),
                child: Container(color: Colors.white),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Ink(
                color: Colors.orange,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _createButton(Icon(Icons.arrow_back), () {
                      if (rotation) {
                        rotationY += 10;
                      } else if (scale) {
                        scaleX += -0.05;
                      } else if (offset) {
                        offsetX -= 0.1;
                      }
                      setState(() {});
                    }),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _createButton(Icon(Icons.arrow_upward_sharp), () {
                          if (rotation) {
                            rotationX += -10;
                          } else if (scale) {
                            scaleY += 0.05;
                          } else if (offset) {
                            offsetY += -0.1;
                          }

                          setState((){});
                        }),
                        _createButton(Icon(Icons.arrow_downward_sharp), () {
                          if (rotation) {
                            rotationX += 10;
                          } else if (scale) {
                            scaleY += -0.05;
                          } else if (offset) {
                            offsetY += 0.1;
                          }

                          setState(() {});
                        }),
                      ],
                    ),
                    _createButton(Icon(Icons.arrow_forward), () {
                      if (rotation) {
                        rotationY += -10;
                      } else if (scale) {
                        scaleX += 0.05;
                      } else if (offset) {
                        offsetX += 0.1;
                      }
                      setState(() {});
                    }),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: _createButton(Icon(Icons.add), () {
                if (rotation) {
                  rotationZ += 10;
                } else if (scale) {
                  scaleZ += 0.05;
                } else if (offset) {
                  offsetZ += 0.1;
                }
                setState(() {});
              }),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _createButton(Icon(Icons.remove), () {
                if (rotation) {
                  rotationZ += -10;
                } else if (scale) {
                  scaleZ += -0.05;
                } else if (offset) {
                  offsetZ += -0.1;
                }
                setState(() {});
              }),
            ),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: figure == null
                ? _createFileLoadBanner(context)
                : _createObserver3D(context)));
  }
}
