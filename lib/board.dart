import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:game_2048/action.dart';

class Board extends StatefulWidget {
  final List<List<int>> tiles;

  final GameActions previousAction;

  final double size;

  static final double middle = 0.5;

  static final int durationInMilliseconds = 300;

  Duration get slideDuration => Duration(milliseconds: (durationInMilliseconds * middle).round());

  Duration get emergeDuration =>
      Duration(milliseconds: (durationInMilliseconds * (1 - middle)).round());

  Board(this.tiles, this.previousAction, this.size);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> with TickerProviderStateMixin<Board> {
  AnimationController _slideController;

  AnimationController _emergeController;

  Animation<double> _slideAnimation;

  Animation<double> _emergeAnimation;

  Animation<double> _mergeAnimation;

  final Tween<double> _emergeTween = Tween<double>(begin: 0.0, end: 1.0);

  final Tween<double> _mergeTween = Tween<double>(begin: 0.0, end: 1.0);

  CombinedState _state;

  @override
  void initState() {
    super.initState();
        this._sizeTween.end = _beginSize;

    _state = CombinedState();

    // init animation controller and animation
    _slideController = AnimationController(duration: this.widget.slideDuration, vsync: this);
    _emergeController = AnimationController(duration: this.widget.emergeDuration, vsync: this);
    _slideController.addStatusListener((AnimationStatus status) {
      switch (status) {
        case AnimationStatus.completed:
          _emergeController.forward();
          break;
        case AnimationStatus.dismissed:
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
      }
    });
    _slideAnimation = _slideController;
    _emergeAnimation = _emergeController;
    _mergeAnimation = CurvedAnimation(parent: _emergeController, curve: Curves.easeOutBack);
    _emergeController.addListener(_handleAnimationChanged);
    _slideController.addListener(_handleAnimationChanged);

    _state.updatePreviousTilesAndAction(this.widget.tiles, this.widget.previousAction);
    _restartControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 185, 173, 162),
          borderRadius: BorderRadius.all(Radius.circular(this.widget.size / 74))),
      width: this.widget.size,
      height: this.widget.size,
      padding: EdgeInsets.all(this.widget.size / 74),
      child: Stack(
        children: <Widget>[
          _buildBackground(),
          _buildForeground(),
        ],
      ),
    );
  }

  void _handleAnimationChanged() {
    setState(() {});
  }

  @override
  void didUpdateWidget(Board oldWidget) {
    super.didUpdateWidget(oldWidget);

    _state.updatePreviousTilesAndAction(this.widget.tiles, this.widget.previousAction);
    _restartControllers();
  }

  void _restartControllers() {
    _slideController.value = 0.0;
    _emergeController.value = 0.0;
    if (this.widget.previousAction == GameActions.newGame) {
      _emergeController.forward();
    } else {
      _calculateState();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emergeController.dispose();
    super.dispose();
  }

  void _updateElement(void Function(int i, int j) updateFunction) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        updateFunction(i, j);
      }
    }
  }

  Widget _buildForeground() {
    double cellWidth = this.widget.size * 8 / 37;
    Widget stable = this._wrap(this._state.nowTiles, cellWidth, (child, di, dj) => child);
    if (this.widget.previousAction == GameActions.newGame) {
      return this._wrap(this._state.nowTiles, cellWidth, (child, di, dj) {
        if (this._state.nowTiles[di][dj] == 0) {
          return child;
        } else {
          return ScaleTransition(
            scale: _emergeTween.animate(_emergeAnimation),
            child: Opacity(
              opacity: this._emergeTween.evaluate(_emergeAnimation),
              child: child,
            ),
          );
        }
      });
    } else {
      return Stack(children: <Widget>[
        this._wrap(this._state.previousTiles, cellWidth, (child, di, dj) {
          if (this._state.previousTiles[di][dj] == 0) {
            return child;
          } else {
            return SlideTransition(
              position: _state.offsetTweens[di][dj].animate(_slideAnimation),
              child: child,
            );
          }
        }),
        this._wrap(this._state.nowTiles, cellWidth, (child, di, dj) {
          if (_state.isMerged[di][dj] == true) {
            return ScaleTransition(
              scale: _mergeTween.animate(_mergeAnimation),
              child: Opacity(
                opacity: this._emergeTween.evaluate(_emergeAnimation),
                child: child,
              ),
            );
          } else if (_state.isMerged[di][dj] == false) {
            return ScaleTransition(
              scale: _emergeTween.animate(_emergeAnimation),
              child: Opacity(
                opacity: this._emergeTween.evaluate(_emergeAnimation),
                child: child,
              ),
            );
          } else {
            return Opacity(opacity: 0.0, child: child);
          }
        })
      ]);
    }
  }

  Widget _buildBackground() {
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

  Widget _wrap(List<List<int>> tiles, double cellWidth,
      Widget Function(Widget child, int di, int dj) wrapFunction) {
    List<Widget> rows = List<Widget>();
    for (int i = 0; i < 4; i++) {
      List<Widget> children = List<Widget>();
      for (int j = 0; j < 4; j++) {
        children.add(wrapFunction(Tile.get(tiles[i][j], cellWidth), i, j));
      }
      Row tmp = Row(children: children);
      rows.add(tmp);
    }
    Column result = Column(children: rows);

    return result;
  }

  void _calculateState() {
    this._state.calculateEverythingForPerformingMoveAnimation();
  }
}

class LinearOutBack extends Curve {
  final double out = 1.2;
  @override
  double transformInternal(double t) {
    double k = 2 * out - 1;
    return out - (out - k).abs();
  }
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
              color: _getColor(value), borderRadius: BorderRadius.all(Radius.circular(width / 32))),
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
      2: Color.alphaBlend(Color.fromARGB(254, 238, 228, 218), Color.fromARGB(255, 249, 246, 242)),
      4: Color.alphaBlend(Color.fromARGB(254, 237, 224, 200), Color.fromARGB(255, 249, 246, 242)),
      8: Color.alphaBlend(Color.fromARGB(254, 242, 177, 121), Color.fromARGB(255, 249, 246, 242)),
      16: Color.alphaBlend(Color.fromARGB(254, 245, 149, 99), Color.fromARGB(255, 249, 246, 242)),
      32: Color.alphaBlend(Color.fromARGB(254, 246, 124, 95), Color.fromARGB(255, 249, 246, 242)),
      64: Color.alphaBlend(Color.fromARGB(254, 246, 94, 5), Color.fromARGB(255, 249, 246, 242)),
      128: Color.alphaBlend(Color.fromARGB(254, 237, 207, 114), Color.fromARGB(255, 249, 246, 242)),
      256: Color.alphaBlend(Color.fromARGB(254, 237, 204, 97), Color.fromARGB(255, 249, 246, 242)),
      512: Color.alphaBlend(Color.fromARGB(254, 237, 200, 80), Color.fromARGB(255, 249, 246, 242)),
      1024: Color.alphaBlend(Color.fromARGB(254, 237, 197, 63), Color.fromARGB(255, 249, 246, 242)),
      2048: Color.alphaBlend(Color.fromARGB(254, 237, 194, 46), Color.fromARGB(255, 249, 246, 242)),
    };

    return colors[value];
  }
}

class CombinedState {
  List<List<int>> previousTiles = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];

  List<List<int>> nowTiles = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];

  static final Offset _beginOffset = Offset(0.0, 0.0);

  // calculated in function _calculateOffsetTweens() {
  List<List<Tween<Offset>>> offsetTweens = [
    [
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0))
    ],
    [
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0))
    ],
    [
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0))
    ],
    [
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0)),
      Tween(begin: _beginOffset, end: Offset(0.0, 0.0))
    ],
  ];

  // calculated in function _calculateOffsetTweens() {
  // null for no animation, true for merge animation, false for emerge animation
  List<List<bool>> isMerged = [
    [
      null,
      null,
      null,
      null,
    ],
    [
      null,
      null,
      null,
      null,
    ],
    [
      null,
      null,
      null,
      null,
    ],
    [
      null,
      null,
      null,
      null,
    ],
  ];

  GameActions previousAction = GameActions.newGame;

  void _handleMoveLeft() {
    void calculateMergeOffsetByOneLine(List<int> nowLine, List<int> previousLine, int lineIndex) {
      Offset calculateOffsetByInt(int offset) {
        return Offset(1.0 * offset, 0.0);
      }

      int nowIndex = 0;
      int previousIndex = 0;
      while (nowIndex < 4 && nowLine[nowIndex] != 0) {
        int diff = nowLine[nowIndex];
        while (diff != 0) {
          if (previousLine[previousIndex] != 0) {
            diff = diff - previousLine[previousIndex];
            if (diff != 0) {
              isMerged[lineIndex][nowIndex] = true;
            }
            offsetTweens[lineIndex][previousIndex].end =
                calculateOffsetByInt(nowIndex - previousIndex);
          }
          previousIndex++;
        }
        nowIndex++;
      }
    }

    for (int i = 0; i < 4; i++) {
      List<int> nowLine = nowTiles[i];
      List<int> previousLine = previousTiles[i];
      //determine if there is newly emerged tile in this line
      int nowSum = 0;
      int previousSum = 0;
      for (int tj = 0; tj < 4; tj++) {
        nowSum += nowLine[tj];
        previousSum += previousLine[tj];
      }
      if (nowSum == previousSum) {
        calculateMergeOffsetByOneLine(nowLine, previousLine, i);
      } else {
        //handle newly emerged tile
        int emergeIndex = 3;
        while (nowLine[emergeIndex] == 0) {
          emergeIndex--;
        }
        this.isMerged[i][emergeIndex] = false;
        List<int> nowLineCopy = [0, 0, 0, 0];
        for (int nowLineIndex = 0; nowLineIndex < 4; nowLineIndex++) {
          nowLineCopy[nowLineIndex] = nowLine[nowLineIndex];
        }
        nowLineCopy[emergeIndex] = 0;
        calculateMergeOffsetByOneLine(nowLineCopy, previousLine, i);
      }
    }
  }

  void _clear() {
    _updateElement((i, j) {
      isMerged[i][j] = null;
      offsetTweens[i][j].end = Offset(0.0, 0.0);
    });
  }

  void calculateEverythingForPerformingMoveAnimation() {
    _clear();
    switch (this.previousAction) {
      case GameActions.moveRight:
        _rotateRight();
        _rotateRight();
        _handleMoveLeft();
        _rotateRight();
        _rotateRight();
        break;
      case GameActions.moveLeft:
        _handleMoveLeft();
        break;
      case GameActions.moveUp:
        _rotateLeft();
        _handleMoveLeft();
        _rotateRight();
        break;
      case GameActions.moveDown:
        _rotateRight();
        _handleMoveLeft();
        _rotateLeft();
        break;
      case GameActions.newGame:
        break;
    }
  }

  void printInfo() {
    void printElement<T>(List<List<T>> matrix, String Function(T element) printOne) {
      for (int i = 0; i < 4; i++) {
        String line = "   ";
        for (int j = 0; j < 4; j++) {
          line += printOne(matrix[i][j]);
        }
        print(line);
      }
    }

    print(" Previous:");
    printElement<int>(this.previousTiles, (element) => element.toString() + " ");
    print(" Action: " + this.previousAction.toString());
    print(" Offsets:");
    printElement<Tween<Offset>>(this.offsetTweens, (element) => element.end.toString() + " ");
    print(" Now:");
    printElement<int>(this.nowTiles, (element) => element.toString() + " ");
  }

  void _rotateLeft() {
    _rotate(true);
  }

  void _rotateRight() {
    _rotate(false);
  }

  void _rotate(bool isLeft) {
    void swapFourElements(List<List<dynamic>> matrix, bool isLeft, int i, int j) {
      dynamic tmp = matrix[i][j];
      if (isLeft) {
        if (matrix[i][j] is Tween<Offset>) {
          void rotateLeft(Tween<Offset> offsetTween) {
            offsetTween.end = Offset((offsetTween.end.dy), 0.0 - (offsetTween.end.dx));
          }

          rotateLeft(matrix[i][j]);
          rotateLeft(matrix[j][3 - i]);
          rotateLeft(matrix[3 - i][3 - j]);
          rotateLeft(matrix[3 - j][i]);
        }
        matrix[i][j] = matrix[j][3 - i];
        matrix[j][3 - i] = matrix[3 - i][3 - j];
        matrix[3 - i][3 - j] = matrix[3 - j][i];
        matrix[3 - j][i] = tmp;
      } else {
        if (matrix[i][j] is Tween<Offset>) {
          void rotateRight(Tween<Offset> offsetTween) {
            offsetTween.end = Offset(0.0 - (offsetTween.end.dy), (offsetTween.end.dx));
          }

          rotateRight(matrix[i][j]);
          rotateRight(matrix[j][3 - i]);
          rotateRight(matrix[3 - i][3 - j]);
          rotateRight(matrix[3 - j][i]);
        }
        matrix[i][j] = matrix[3 - j][i];
        matrix[3 - j][i] = matrix[3 - i][3 - j];
        matrix[3 - i][3 - j] = matrix[j][3 - i];
        matrix[j][3 - i] = tmp;
      }
    }

    for (int i = 0; i < 2; i++) {
      for (int j = i; j < (3 - i); j++) {
        swapFourElements(previousTiles, isLeft, i, j);
        swapFourElements(nowTiles, isLeft, i, j);
        swapFourElements(offsetTweens, isLeft, i, j);
        swapFourElements(isMerged, isLeft, i, j);
      }
    }
  }

  void _updateElement(void Function(int i, int j) updateFunction) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        updateFunction(i, j);
      }
    }
  }

  void updatePreviousTilesAndAction(List<List<int>> tiles, GameActions action) {
    this.previousAction = action;
    _updateElement((i, j) {
      this.previousTiles[i][j] = this.nowTiles[i][j];
      this.nowTiles[i][j] = tiles[i][j];
    });
  }
}
