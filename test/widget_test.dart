// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:game_2048/action.dart';
import 'package:game_2048/board.dart';

void main() {
  test("test movement case 1", () {
    CombinedState state = CombinedState();
    state.updatePreviousTilesAndAction([
      [2, 0, 0, 0],
      [2, 0, 0, 0],
      [4, 0, 0, 0],
      [0, 0, 0, 0]
    ], GameActions.newGame);
    state.updatePreviousTilesAndAction([
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [4, 4, 0, 0],
      [4, 0, 0, 0]
    ], GameActions.moveDown);
    state.calculateEverythingForPerformingMoveAnimation();
    expect(state.offsetTweens[0][0].end, Offset(0.0,2.0));
    expect(state.offsetTweens[1][0].end, Offset(0.0,1.0));
    expect(state.offsetTweens[2][0].end, Offset(0.0,1.0));
    expect(state.isMerged[2][1], false);
    expect(state.isMerged[2][0], true);
  });

  test("test movement case ", () {
    CombinedState state = CombinedState();
    state.updatePreviousTilesAndAction([
      [0, 0, 0, 0],
      [0, 0, 0, 2],
      [0, 0, 0, 4],
      [0, 0, 0, 0]
    ], GameActions.newGame);
    state.updatePreviousTilesAndAction([
      [0, 0, 0, 0],
      [2, 0, 0, 2],
      [4, 0, 0, 0],
      [0, 0, 0, 0]
    ], GameActions.moveLeft);
    state.calculateEverythingForPerformingMoveAnimation();
    expect(state.offsetTweens[1][3].end, Offset(-3.0,0.0));
    expect(state.offsetTweens[2][3].end, Offset(-3.0,0.0));
    expect(state.isMerged[1][3], false);
  });

  test("test movement case 3", () {
    CombinedState state = CombinedState();
    state.updatePreviousTilesAndAction([
      [0, 0, 0, 0],
      [4, 0, 0, 0],
      [0, 0, 0, 0],
      [4, 4, 4, 0]
    ], GameActions.newGame);
    state.updatePreviousTilesAndAction([
      [0, 0, 0, 0],
      [4, 0, 0, 0],
      [0, 0, 0, 0],
      [8, 4, 0, 2]
    ], GameActions.moveLeft);
    state.calculateEverythingForPerformingMoveAnimation();
    expect(state.offsetTweens[3][1].end, Offset(-1.0,0.0));
    expect(state.offsetTweens[3][2].end, Offset(-1.0,0.0));
    expect(state.isMerged[3][0], true);
    expect(state.isMerged[3][3], false);
    expect(state.isMerged[3][3], false);
  });


}
