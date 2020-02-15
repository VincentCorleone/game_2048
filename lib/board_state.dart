import 'dart:math';

import 'package:game_2048/action.dart';

class BoardState {
  List<List<int>> tiles;
  int _numOfEmptyCells;

  bool isDead = false;

  bool isSuccess = false;

  int score = 0;

  int index = 0;

  GameActions previousAction;

  final _random = new Random();

  BoardState.fromAnother(BoardState state) {
    this.tiles = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        this.tiles[i][j] = state.tiles[i][j];
      }
    }
    _countEmptyCells();
    this.isDead = state.isDead;
    this.score = state.score;
    this.index = state.index;
    this.previousAction = state.previousAction;
  }

  void checkIsDead(){
    bool isFailed = true;

    BoardState tmp;


    tmp = BoardState.fromAnother(this);
    tmp.moveLeft();
    isFailed = isFailed && (this.isTilesEqual(tmp.tiles));

    tmp = BoardState.fromAnother(this);
    tmp.moveRight();
    isFailed = isFailed && (this.isTilesEqual(tmp.tiles));

    tmp = BoardState.fromAnother(this);
    tmp.moveUp();
    isFailed = isFailed && (this.isTilesEqual(tmp.tiles));

    tmp = BoardState.fromAnother(this);
    tmp.moveDown();
    isFailed = isFailed && (this.isTilesEqual(tmp.tiles));

    this.isDead = isFailed;
  }

  void checkIsSuccess(){
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (this.tiles[i][j] == 2048) {
          this.isSuccess = true;
          return;
        }
      }
    }
    this.isSuccess = false;
  }


  bool isTilesEqual(List<List<int>> tiles) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (this.tiles[i][j] != tiles[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  BoardState.newGame() {
    this.tiles = [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ];
    this._numOfEmptyCells = 16;
    this.addNewNumber();
    this.addNewNumber();
    this.previousAction = GameActions.newGame;
  }

  void addNewNumber() {
    int position = _random.nextInt(_numOfEmptyCells);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (this.tiles[i][j] == 0) {
          if (position == 0) {
            this.tiles[i][j] = _newNumber();
            this._numOfEmptyCells--;
            return;
          }
          position--;
        }
      }
    }
  }

  int _newNumber() {
    int r = _random.nextInt(10);
    if (r == 0) {
      return 4;
    } else {
      return 2;
    }
  }

  void rotateLeft() {
    _rotate(true);
  }

  void rotateRight() {
    _rotate(false);
  }

  void _rotate(bool isLeft) {
    for (int i = 0; i < 2; i++) {
      for (int j = i; j < (3 - i); j++) {
        int tmp = this.tiles[i][j];
        if (isLeft) {
          this.tiles[i][j] = this.tiles[j][3 - i];
          this.tiles[j][3 - i] = this.tiles[3 - i][3 - j];
          this.tiles[3 - i][3 - j] = this.tiles[3 - j][i];
          this.tiles[3 - j][i] = tmp;
        } else {
          this.tiles[i][j] = this.tiles[3 - j][i];
          this.tiles[3 - j][i] = this.tiles[3 - i][3 - j];
          this.tiles[3 - i][3 - j] = this.tiles[j][3 - i];
          this.tiles[j][3 - i] = tmp;
        }
      }
    }
  }

  void _deleteBubble(List<int> line) {
    //delete bubble
    List<int> nonZeros = [];
    for (int i = 0; i < 4; i++) {
      if (line[i] != 0) {
        nonZeros.add(line[i]);
      }
      line[i] = 0;
    }
    for (int i = 0; i < nonZeros.length; i++) {
      line[i] = nonZeros[i];
    }
  }

  void _countEmptyCells() {
    this._numOfEmptyCells = 0;
    for (List<int> line in tiles) {
      for (int value in line) {
        if (value == 0) {
          this._numOfEmptyCells++;
        }
      }
    }
  }

  void moveLeft() {
    for (List<int> line in this.tiles) {
      _deleteBubble(line);
      //merge
      for (int i = 0; i < 3; i++) {
        if (line[i] == line[i + 1]) {
          line[i] = line[i] << 1;
          this.score += line[i];
          line[i + 1] = 0;
        }
      }
      _deleteBubble(line);
      _countEmptyCells();
    }

  }

  void moveRight() {
    this.rotateRight();
    this.rotateRight();
    this.moveLeft();
    this.rotateRight();
    this.rotateRight();

  }

  void moveUp() {
    this.rotateLeft();
    this.moveLeft();
    this.rotateRight();
  }

  void moveDown() {
    this.rotateRight();
    this.moveLeft();
    this.rotateLeft();
  }
}
