import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:game_2048/board_state.dart';
import 'package:game_2048/reducer.dart';
import 'package:redux/redux.dart';
import 'package:game_2048/ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: Store<BoardState>(movementReducer, initialState: BoardState.newGame()),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: UI(),
      ),
    );
  }
}