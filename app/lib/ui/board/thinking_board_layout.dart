import 'package:chessroad/cchess/cc_base.dart';
import 'package:chessroad/config/local_data.dart';
import 'package:chessroad/engine/pikafish_engine.dart';
import 'package:chessroad/game/board_state.dart';
import 'package:chessroad/ui/thinking_board_painter.dart';
import 'package:flutter/material.dart';

import 'pieces_layout.dart';

class ThinkingBoardLayout extends StatefulWidget {
  //
  final BoardState boardState;

  final PiecesLayout layoutParams;

  const ThinkingBoardLayout(this.boardState, this.layoutParams, {Key? key}) : super(key: key);

  @override
  State createState() => _PiecesLayoutState();
}

class _PiecesLayoutState extends State<ThinkingBoardLayout> {
  //
  @override
  Widget build(BuildContext context) {
    //
    final moves = <Move>[];

    if (PikafishEngine().state != EngineState.searching && widget.boardState.bestmove?.ponder != null) {
      //
      moves.add(Move.fromEngineMove(widget.boardState.bestmove!.ponder!));
      //
    } else if (widget.boardState.engineInfo != null) {
      //
      var pvs = widget.boardState.engineInfo!.pvs;

      if (pvs.length > 2) {
        pvs = pvs.sublist(0, 2);
      }

      moves.addAll(pvs.map((move) => Move.fromEngineMove(move)));
    }

    final layout = widget.layoutParams.buildPiecesLayout(context);

    return Stack(children: [
      layout,
      if (LocalData().thinkingArrowEnabled.value)
        CustomPaint(
          painter: ThinkingBoardPainter(moves, widget.layoutParams),
        )
    ]);
  }
}
