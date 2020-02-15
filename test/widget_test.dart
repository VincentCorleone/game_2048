// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:game_2048/board_state.dart';

void printMatrix(BoardState state){
  for(List<int> line in state.tiles){
    print(line);
  }
}

void main() {
  List<int> a = [1,2,3,4];
  List<int> b = [1,2,3,4];

}