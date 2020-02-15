import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:game_2048/action.dart';

class Board extends ImplicitlyAnimatedWidget {
  final List<List<int>> tiles;

  final GameActions previousAction;

  final double size;

  static final double middle = 0.8;

  static final int durationInMilliseconds = 300;

  Board(this.tiles, this.previousAction, this.size)
      : super(
            duration: previousAction == GameActions.newGame
                ? Duration(
                    milliseconds: (durationInMilliseconds * middle).round())
                : Duration(milliseconds: durationInMilliseconds));

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _BoardState();
  }
}

class _BoardState extends ImplicitlyAnimatedWidgetState<Board> {
  List<List<int>> previousTiles;

  Tween<Offset> _position =
      Tween<Offset>(begin: Offset.zero, end: Offset(2.0, 0.0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 185, 173, 162),
          borderRadius:
              BorderRadius.all(Radius.circular(this.widget.size / 74))),
      width: this.widget.size,
      height: this.widget.size,
      padding: EdgeInsets.all(this.widget.size / 74),
      child: Stack(
        children: <Widget>[
          buildBackground(),
          buildForeground(this.widget.tiles),
        ],
      ),
    );
  }

  List<List<Offset>> calculateOffset() {
    return null;
  }

  @override
  void forEachTween(visitor) {
    print(this.widget.previousAction);
    print("previous: " + this.previousTiles.toString());
    print("now: " + this.widget.tiles.toString());
    //    visitor(
//      _position,
//      this.widget.offset,
//        (value) => Tween<Offset>(begin: value)
//    );

    this.previousTiles = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        this.previousTiles[i][j] = this.widget.tiles[i][j];
      }
    }
  }

  Widget buildBackground() {
    double cellWidth = this.widget.size * 8 / 37;
    double cellBorderRadius = cellWidth / 32;
    double cellMargin = cellWidth / 16;
    Container cell = Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 203, 193, 182),
          borderRadius: BorderRadius.all(Radius.circular(cellBorderRadius))),
      width: cellWidth,
      height: cellWidth,
      margin: EdgeInsets.all(cellMargin),
    );
    List<Widget> cells = List.filled(16, cell);

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      children: cells,
    );
  }

  Widget buildForeground(List<List<int>> tiles) {
    double cellWidth = this.widget.size * 8 / 37;
    return Column(
      children: tiles
          .map((line) => Row(
                children:
                    line.map((value) => Tile.get(value, cellWidth)).toList(),
              ))
          .toList(),
    );
  }
}

class NewGamePara {
  double size;

  ///  0 being transparent and 255 being fully opaque.
  double alpha;

  NewGamePara operator +(NewGamePara other) => NewGamePara(size + other.size, alpha + other.alpha);

  NewGamePara operator -(NewGamePara other) => NewGamePara(size - other.size, alpha - other.alpha);

  NewGamePara(this.size, this.alpha);
}

class NewGameTween extends Tween<NewGamePara>{

  NewGameTween();
}

class PositionTween extends Tween<Offset> {
  final double middle;

  PositionTween(this.middle);

}

class Tile {
  static Map<int, Widget> _instances = HashMap();

  static Widget get(int value, double width) {
    if (_instances[value] != null) {
      return _instances[value];
    } else {
      Widget tmp;
      if (value == 0) {
        tmp = tmp = Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(0, 203, 193, 182),
              borderRadius: BorderRadius.all(Radius.circular(width / 32))),
          width: width,
          height: width,
          margin: EdgeInsets.all(width / 16),
        );
      } else {
        tmp = Container(
          decoration: BoxDecoration(
              color: _getColor(value),
              borderRadius: BorderRadius.all(Radius.circular(width / 32))),
          width: width,
          height: width,
          margin: EdgeInsets.all(width / 16),
          child: Center(
              child: Text(
            value.toString(),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: _getTextSize(value),
                color: _getTextColor(value)),
          )),
        );
      }
      _instances[value] = tmp;
      return tmp;
    }
  }

  static double _getTextSize(int value) {
    if (value < 127) {
      return 50;
    } else if (value < 255) {
      return 40;
    } else if (value < 1023) {
      return 36;
    } else {
      return 30;
    }
  }

  static Color _getTextColor(int value) {
    if (value < 7) {
      return Color.fromARGB(255, 118, 110, 102);
    } else {
      return Color.fromARGB(255, 249, 246, 243);
    }
  }

  static Color _getColor(int value) {
    Map<int, Color> colors = {
      2: Color.alphaBlend(Color.fromARGB(254, 238, 228, 218),
          Color.fromARGB(255, 249, 246, 242)),
      4: Color.alphaBlend(Color.fromARGB(254, 237, 224, 200),
          Color.fromARGB(255, 249, 246, 242)),
      8: Color.alphaBlend(Color.fromARGB(254, 242, 177, 121),
          Color.fromARGB(255, 249, 246, 242)),
      16: Color.alphaBlend(Color.fromARGB(254, 245, 149, 99),
          Color.fromARGB(255, 249, 246, 242)),
      32: Color.alphaBlend(Color.fromARGB(254, 246, 124, 95),
          Color.fromARGB(255, 249, 246, 242)),
      64: Color.alphaBlend(
          Color.fromARGB(254, 246, 94, 5), Color.fromARGB(255, 249, 246, 242)),
      128: Color.alphaBlend(Color.fromARGB(254, 237, 207, 114),
          Color.fromARGB(255, 249, 246, 242)),
      256: Color.alphaBlend(Color.fromARGB(254, 237, 204, 97),
          Color.fromARGB(255, 249, 246, 242)),
      512: Color.alphaBlend(Color.fromARGB(254, 237, 200, 80),
          Color.fromARGB(255, 249, 246, 242)),
      1024: Color.alphaBlend(Color.fromARGB(254, 237, 197, 63),
          Color.fromARGB(255, 249, 246, 242)),
      2048: Color.alphaBlend(Color.fromARGB(254, 237, 194, 46),
          Color.fromARGB(255, 249, 246, 242)),
    };

    return colors[value];
  }
}
