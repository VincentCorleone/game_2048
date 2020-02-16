import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:game_2048/action.dart';

class Board extends ImplicitlyAnimatedWidget {
  final List<List<int>> tiles;

  final GameActions previousAction;

  final double size;

  static final double middle = 0.8;

  static final int durationInMilliseconds = 1000;

  Board(this.tiles, this.previousAction, this.size)
      : super(
            duration: previousAction == GameActions.newGame
                ? Duration(
                    milliseconds:
                        (durationInMilliseconds * (1 - middle)).round())
                : Duration(milliseconds: durationInMilliseconds));

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _BoardState();
  }
}

class _BoardState extends AnimatedWidgetBaseState<Board> {
  List<List<int>> previousTiles = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];

  OpacityTween _opacityTween;
  final double _beginOpacity = 0.2;
  SizeTween _sizeTween;
  final double _beginSize = 0.1;
  Tween<double> _useless;



  @override
  void initState() {
    super.initState();
    controller.addStatusListener((AnimationStatus status) {
      if (this.widget.previousAction == GameActions.newGame &&
          status == AnimationStatus.completed) {
        this._opacityTween.end = _beginOpacity;
        this._sizeTween.end = _beginSize;
      }
    });
  }

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

  @override
  void forEachTween(visitor) {
//    print(this.widget.previousAction);
//    print("previous: " + this.previousTiles.toString());
//    print("now: " + this.widget.tiles.toString());

    double cellWidth = this.widget.size * 8 / 37;
    if (this.widget.previousAction == GameActions.newGame) {
      this._opacityTween = visitor(_opacityTween, 1.0,
          (value) => OpacityTween(begin: _beginOpacity, end: value));
      this._sizeTween =
          visitor(_sizeTween, 1.0, (value) => SizeTween(begin: _beginSize, end: value));
      // force animation
      this._useless = visitor(_useless, 1.0, (value) => SizeTween(begin: 0.0, end: 0.0));
    }
  }

  @override
  void didUpdateTweens() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        this.previousTiles[i][j] = this.widget.tiles[i][j];
      }
    }
  }

  List<List<Offset>> calculateOffset() {
    return null;
  }

  Widget _wrap(List<List<int>> tiles,double cellWidth,Widget Function(Widget child) wrapFunction){
    return Column(
      children: tiles
          .map((line) => Row(
        children:
        line.map((value) => wrapFunction(Tile.get(value, cellWidth))).toList(),
      ))
          .toList(),
    );
  }

  Widget buildForeground(List<List<int>> tiles) {
    double cellWidth = this.widget.size * 8 / 37;
//    print(_opacityTween.toString());
    Widget stable = this._wrap(tiles, cellWidth, (child)=>child);
    if (this.widget.previousAction == GameActions.newGame) {
//      print(_opacityTween.evaluate(animation).toString());
      return EmergeWidgetTween(
              begin: this._wrap(tiles, cellWidth, (child)=> ScaleTransition(
                scale: _sizeTween.animate(animation),
                child: Opacity(
                  opacity: this._opacityTween.evaluate(animation),
                  child: child,
                ),
              )),
              end: stable)
          .evaluate(animation);
    }
    return stable;
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
}

class OpacityTween extends Tween<double> {
  OpacityTween({double begin, double end}) : super(begin: begin, end: end);
}

class SizeTween extends Tween<double> {
  SizeTween({double begin, double end}) : super(begin: begin, end: end);
}

class EmergeWidgetTween extends Tween<Widget> {
  EmergeWidgetTween({Widget begin, Widget end}) : super(begin: begin, end: end);

  @override
  Widget lerp(double t) {
    if (t == 1.0) {
      return end;
    } else {
      return begin;
    }
  }
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
                fontSize: _getTextSize(value) * width / 80,
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
