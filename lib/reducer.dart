import 'package:game_2048/action.dart';
import 'package:game_2048/board_state.dart';

BoardState movementReducer(BoardState state, dynamic action){
  state.previousAction = action;
  if(action == GameActions.newGame){
    return BoardState.newGame();
  }
  BoardState newState = BoardState.fromAnother(state);
  if(action == GameActions.moveLeft){
    state.moveLeft();
  }else if(action == GameActions.moveRight){
    state.moveRight();
  }else if(action == GameActions.moveUp){
    state.moveUp();
  }else if(action == GameActions.moveDown){
    state.moveDown();
  }
  if(newState.isTilesEqual(state.tiles)){
    return state;
  }
  state.addNewNumber();
  state.checkIsDead();
  state.checkIsSuccess();

  return state;
}