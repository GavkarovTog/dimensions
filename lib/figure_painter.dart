import 'package:flutter/material.dart';
import 'package:dimensions/utils.dart';

class FigurePainter extends CustomPainter {
  Camera camera;
  Figure figure;
  List<TransformationCommand> rotations;
  List<TransformationCommand> scales;
  List<TransformationCommand> offsets;
  List<TransformationCommand> mirrors;

  FigurePainter(
    this.figure,
    this.rotations,
    this.scales,
    this.offsets,
    this.mirrors,
    this.camera
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint vertexBrush = Paint()
      ..color = Colors.red
      ..strokeWidth = 10;

    Paint edgesBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    Figure resultingFigure = figure;
    
    for (var scale in scales) {
      resultingFigure = scale.transform(resultingFigure);
    }

    for (var rotation in rotations) {
      resultingFigure = rotation.transform(resultingFigure);
    }

    for (var mirror in mirrors) {
      resultingFigure = mirror.transform(resultingFigure);
    }

    for (var offset in offsets) {
      resultingFigure = offset.transform(resultingFigure);
    }

    double aspectRation = size.width / size.height;
    List<Vertex4> vertices = resultingFigure.getVertices();
    List<List<int>> facing = resultingFigure.getEdges();

    Vertex4? maxVertex;
    for (Vertex4 vertex in vertices) {
      if (maxVertex == null) {
        maxVertex = vertex;
        continue;
      }

      if (maxVertex.diff(camera.position).length < vertex.diff(camera.position).length) {
        maxVertex = vertex;
      }
    }

    List<Vertex4> minVertices = [];
    for (Vertex4 vertex in vertices) {
      if (vertex.diff(camera.position).length == maxVertex!.diff(camera.position).length) {
        minVertices.add(vertex);
      }
    }

    for (List<int> edges in facing) {
      int previous = -1;

      bool isHidden = false;
      for (int edgeIndex in edges) {
        if (minVertices.contains(vertices[edgeIndex - 1])) {
          isHidden = true;
          break;
        }
      }

      if (isHidden) {
        continue;
      }

      for (int edgeIndex in edges) {
        if (previous == -1) {
          previous = edgeIndex;
          continue;
        }

        Vertex4 firstProjected = project2D(
            perspective(
                vertices[previous - 1],
                camera.position
            )
        );

        Vertex4 secondProjected = project2D(
            perspective(
                vertices[edgeIndex - 1],
                camera.position
            )
        );

        double firstX = firstProjected.x * size.width / 2 + size.width / 2;
        double firstY = firstProjected.y * size.height / 2 * aspectRation +
            size.height / 2;

        double secondX = secondProjected.x * size.width / 2 + size.width / 2;
        double secondY = secondProjected.y * size.height / 2 * aspectRation +
            size.height / 2;

        canvas.drawLine(
            Offset(firstX, firstY), Offset(secondX, secondY), edgesBrush
        );

        previous = edgeIndex;
      }

      Vertex4 firstProjected = project2D(
          perspective(
              vertices[previous - 1],
              camera.position
          )
      );

      Vertex4 secondProjected = project2D(
          perspective(
              vertices[edges[0] - 1],
              camera.position
          )
      );

      canvas.drawLine(
        Offset(firstProjected.x * size.width / 2 + size.width / 2,
            firstProjected.y * size.height / 2 * aspectRation + size.height / 2),
        Offset(secondProjected.x * size.width / 2 + size.width / 2,
            secondProjected.y * size.height / 2 * aspectRation + size.height / 2),
        edgesBrush
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
