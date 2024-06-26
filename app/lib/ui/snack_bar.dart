import 'package:chessroad/main.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';

void showSnackBar(
  String text, {
  bool shortDuration = false,
  Color? bgColor,
  SnackBarAction? action,
}) {
  //
  ScaffoldMessenger.of(ChessRoadApp.context).showSnackBar(
    SnackBar(
      backgroundColor: bgColor ?? GameColors.primary,
      duration: Duration(milliseconds: shortDuration ? 1000 : 4000),
      content: Text(text),
      action: action,
    ),
  );
}
