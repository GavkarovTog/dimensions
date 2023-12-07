import 'dart:math';

abstract class TransformationCommand {
  double xStep;
  double yStep;
  double zStep;

  TransformationCommand(this.xStep, this.yStep, this.zStep);

  Figure transform(Figure figure);
}

class RotationCommand extends TransformationCommand {
  RotationCommand(super.xStep, super.yStep, super.zStep);

  @override
  Figure transform(Figure figure) {
    return RotationTransform(figure, xStep, yStep, zStep);
  }
}

class ScaleCommand extends TransformationCommand {
  ScaleCommand(super.xStep, super.yStep, super.zStep);

  @override
  Figure transform(Figure figure) {
    return ScalingTransform(figure, xStep, yStep, zStep);
  }
}

class OffsetCommand extends TransformationCommand {
  OffsetCommand(super.xStep, super.yStep, super.zStep);

  @override
  Figure transform(Figure figure) {
    return MovementTransform(figure, xStep, yStep, zStep);
  }
}

class MirrorCommand extends TransformationCommand {
  MirrorCommand(super.xStep, super.yStep, super.zStep);

  @override
  Figure transform(Figure figure) {
    return MirrorTransform(figure, xStep == 1, yStep == 1, zStep == 1);
  }
}

Vertex4 rotateX(Vertex4 vertex, double angle) {
  double radians = angle * pi / 180;

  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, cos(radians), -sin(radians), 0),
          Vertex4(0, sin(radians), cos(radians), 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 rotateY(Vertex4 vertex, double angle) {
  double radians = angle * pi / 180;

  return vertex.multiply(
      Matrix4(
          Vertex4(cos(radians), 0, sin(radians), 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(-sin(radians), 0, cos(radians), 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 rotateZ(Vertex4 vertex, double angle) {
  double radians = angle * pi / 180;

  return vertex.multiply(
      Matrix4(
          Vertex4(cos(radians), -sin(radians), 0, 0),
          Vertex4(sin(radians), cos(radians), 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 mirrorX(Vertex4 vertex4) {
  return vertex4.multiply(
      Matrix4(
          Vertex4(-1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 mirrorY(Vertex4 vertex4) {
  return vertex4.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, -1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 mirrorZ(Vertex4 vertex4) {
  return vertex4.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, -1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 moveX(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(component, 0, 0, 1)
      )
  );
}

Vertex4 moveY(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, component, 0, 1)
      )
  );
}

Vertex4 moveZ(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, component, 1)
      )
  );
}

Vertex4 scaleX(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(component, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 scaleY(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, component, 0, 0),
          Vertex4(0, 0, 1, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 scaleZ(Vertex4 vertex, double component) {
  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 0),
          Vertex4(0, 1, 0, 0),
          Vertex4(0, 0, component, 0),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 perspective(Vertex4 vertex, Vertex4 from) {
  Vertex4 distance = Vertex4(
      vertex.x - from.x,
      vertex.y - from.y,
      vertex.z - from.z,
      vertex.w - from.w
  );

  return vertex.multiply(
      Matrix4(
          Vertex4(1, 0, 0, 1 / distance.x),
          Vertex4(0, 1, 0, 1 / distance.y),
          Vertex4(0, 0, 1, 1 / distance.z),
          Vertex4(0, 0, 0, 1)
      )
  );
}

Vertex4 project2D(Vertex4 vertex) {
  return Vertex4(
    vertex.x / vertex.w,
    vertex.y / vertex.w,
    vertex.z / vertex.w,
    vertex.w / vertex.w
  );
}

class Vertex4 {
  double _x;
  double _y;
  double _z;
  double _w;

  Vertex4(this._x, this._y, this._z, [this._w = 1.0]);

  double get x {
    return _x;
  }

  double get y {
    return _y;
  }

  double get z {
    return _z;
  }

  double get w {
    return _w;
  }

  double get length {
    return sqrt(x * x + y * y + z * z + w * w);
  }

  @override
  String toString() {
    return "Vertex4($x, $y, $z, $w)";
  }

  Vertex4 diff(Vertex4 vertex) {
    return Vertex4(x - vertex.x, y - vertex.y, z - vertex.z, w - vertex.w);
  }

  Vertex4 multiply(Matrix4 matrix) {
    return Vertex4(
      x * matrix.col1.x + y * matrix.col1.y + z * matrix.col1.z + w * matrix.col1.w,
      x * matrix.col2.x + y * matrix.col2.y + z * matrix.col2.z + w * matrix.col2.w,
      x * matrix.col3.x + y * matrix.col3.y + z * matrix.col3.z + w * matrix.col3.w,
      x * matrix.col4.x + y * matrix.col4.y + z * matrix.col4.z + w * matrix.col4.w,
    );
  }
}

class Matrix4 {
  late Vertex4 col1;
  late Vertex4 col2;
  late Vertex4 col3;
  late Vertex4 col4;

  Matrix4(
      Vertex4 row1,
      Vertex4 row2,
      Vertex4 row3,
      Vertex4 row4
      ) {

    col1 = Vertex4(
      row1.x,
      row2.x,
      row3.x,
      row4.x
    );

    col2 = Vertex4(
        row1.y,
        row2.y,
        row3.y,
        row4.y
    );

    col3 = Vertex4(
        row1.z,
        row2.z,
        row3.z,
        row4.z
    );

    col4 = Vertex4(
        row1.w,
        row2.w,
        row3.w,
        row4.w
    );
  }
}

class Camera {
  Vertex4 _position;

  Camera(this._position);

  Vertex4 get position {
    return _position;
  }

  void rotate(double angleX, double angleY, double angleZ) {
    _position = rotateZ(rotateY(rotateX(_position, angleX), angleY), angleZ);
  }
}

abstract class Figure {
  List<Vertex4> getVertices();
  List<List<int>> getEdges();
}

class Figure3D implements Figure {
  List<Vertex4> _vertices = [];
  List<List<int>> _edges = [];

  static Figure3D parse(String toParse) {
    Figure3D figure = Figure3D();

    RegExp regExpForVertexRow = RegExp(r'v +-?(([1-9]\d+(.\d+)?)|(\d(.\d+)?)) +-?(([1-9]\d+(.\d+)?)|(\d(.\d+)?)) +-?(([1-9]\d+(.\d+)?)|(\d(.\d+)?))( +-?(([1-9]\d+(.\d+)?)|(\d(.\d+)?)))?');
    RegExp regExpForVertex = RegExp(r'-?(([1-9]\d+(.\d+)?)|(\d(.\d+)?))');

    RegExp regExpForFacing = RegExp(r'f (\d+(\/\d+(\/\d+)?)?)( +(\d+(\/\d+(\/\d+)?)?))*');
    RegExp regExpForFaceTriplet = RegExp(r'(\d+(\/\d+(\/\d+)?)?)');
    RegExp regExpForFaceValue = RegExp(r'\d+');

    for (RegExpMatch row in regExpForVertexRow.allMatches(toParse)) {
      List<double> vertexValues = [];

      for (RegExpMatch value in regExpForVertex.allMatches(row[0]!)) {
        vertexValues.add(double.parse(value[0]!));
      }

      double w = 1.0;
      if (vertexValues.length == 4) {
        w = vertexValues[3];
      }

      figure._vertices.add(Vertex4(vertexValues[0], vertexValues[1], vertexValues[2], w));
    }

    for (RegExpMatch facing in regExpForFacing.allMatches(toParse)) {
      List<int> facingValues = [];

      for (RegExpMatch triplet in regExpForFaceTriplet.allMatches(facing[0]!)) {
        for (RegExpMatch faceValue in regExpForFaceValue.allMatches(triplet[0]!)) {
          facingValues.add(
            int.parse(faceValue[0].toString())
          );
          break;
        }
      }

      print(facingValues);
      figure._edges.add(facingValues);
    }

    print("edges: ${figure._edges}");

    return figure;
  }

  @override
  List<Vertex4> getVertices() {
    return _vertices;
  }

  @override
  List<List<int>> getEdges() {
    return _edges;
  }
}

class RotationTransform implements Figure {
  Figure _figure;
  double angleX;
  double angleY;
  double angleZ;

  RotationTransform(this._figure, this.angleX, this.angleY, this.angleZ);

  @override
  List<Vertex4> getVertices() {
    List<Vertex4> vertices = _figure.getVertices();

    List<Vertex4> result = [];
    for (Vertex4 vertex in vertices) {
      result.add(
        rotateZ(rotateY(rotateX(vertex, angleX), angleY), angleZ)
      );
    }

    return result;
  }

  @override
  List<List<int>> getEdges() {
    return _figure.getEdges();
  }
}

class MovementTransform implements Figure {
  final Figure _figure;
  double x;
  double y;
  double z;

  MovementTransform(this._figure, this.x, this.y, this.z);

  @override
  List<Vertex4> getVertices() {
    List<Vertex4> vertices = _figure.getVertices();

    List<Vertex4> result = [];
    for (Vertex4 vertex in vertices) {
      result.add(
          moveZ(moveY(moveX(vertex, x), y), z)
      );
    }

    return result;
  }

  @override
  List<List<int>> getEdges() {
    return _figure.getEdges();
  }
}

class MirrorTransform implements Figure {
  final Figure _figure;
  bool x;
  bool y;
  bool z;

  MirrorTransform(this._figure, this.x, this.y, this.z);

  @override
  List<Vertex4> getVertices() {
    List<Vertex4> vertices = _figure.getVertices();

    List<Vertex4> result = [];
    for (Vertex4 vertex in vertices) {
      Vertex4 tmp = vertex;

      if (x) {
        tmp = mirrorX(tmp);
      }

      if (y) {
        tmp = mirrorY(tmp);
      }

      if (z) {
        tmp = mirrorZ(tmp);
      }

      result.add(
        tmp
      );
    }

    return result;
  }

  @override
  List<List<int>> getEdges() {
    return _figure.getEdges();
  }
}

class ScalingTransform implements Figure {
  final Figure _figure;
  double x;
  double y;
  double z;

  ScalingTransform(this._figure, this.x, this.y, this.z);

  @override
  List<Vertex4> getVertices() {
    List<Vertex4> vertices = _figure.getVertices();

    List<Vertex4> result = [];
    for (Vertex4 vertex in vertices) {
      result.add(
          scaleZ(scaleY(scaleX(vertex, x), y), z)
      );
    }

    return result;
  }

  @override
  List<List<int>> getEdges() {
    return _figure.getEdges();
  }
}