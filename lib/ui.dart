import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:game_2048/board_state.dart';
import 'package:game_2048/action.dart';
import 'package:game_2048/board.dart';

class UI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("2048")),
        body: StoreConnector<BoardState, BoardState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return GestureDetector(
                onHorizontalDragEnd: (DragEndDetails d) {
                  if (!state.isDead && !state.isSuccess) {
                    if (d.primaryVelocity > 0) {
                      StoreProvider.of<BoardState>(context)
                          .dispatch(GameActions.moveRight);
                    } else {
                      StoreProvider.of<BoardState>(context)
                          .dispatch(GameActions.moveLeft);
                    }
                  }
                },
                onVerticalDragEnd: (DragEndDetails d) {
                  if (!state.isDead && !state.isSuccess) {
                    if (d.primaryVelocity > 0) {
                      StoreProvider.of<BoardState>(context)
                          .dispatch(GameActions.moveDown);
                    } else {
                      StoreProvider.of<BoardState>(context)
                          .dispatch(GameActions.moveUp);
                    }
                  }
                },
                child: Container(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 2 / 41,
                    ),
                    color: Color.fromARGB(255, 250, 248, 240),
                    child: Center(
                      child: Column(children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              state.score.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Color.fromARGB(255, 118, 110, 102)),
                            ),
                            RaisedButton(
                                child: Text("New Game"),
                                onPressed: () {
                                  StoreProvider.of<BoardState>(context)
                                      .dispatch(GameActions.newGame);
                                })
                          ],
                        ),
                        Board(
                          state.tiles,
                          state.previousAction,
                          MediaQuery.of(context).size.width * 37 / 41,
                        ),
                        Center(
                            child: Text(
                          state.isDead
                              ? "You failed."
                              : (state.isSuccess ? "You win!" : ""),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              color: Colors.amber),
                        )),
                      ]),
                    )),
              );
            }));
  }
}
