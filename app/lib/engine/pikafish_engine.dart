import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pikafish_engine/pikafish.dart';

import '../cchess/position.dart';
import '../common/prt.dart';
import '../config/local_data.dart';
import 'engine.dart';
import 'pikafish_config.dart';

enum EngineState { unknown, ready, searching, pondering, hinting }

class PikafishEngine {
  //
  factory PikafishEngine() => _instance;
  static final PikafishEngine _instance = PikafishEngine._();

  PikafishEngine._() {
    _setupEngine();
  }

  late Pikafish _engine;
  late StreamSubscription _subscription;

  EngineCallback? callback;
  EngineState _state = EngineState.unknown;

  Future<void> startup() async {
    //
    while (_engine.state.value == PikafishState.starting) {
      await Future.delayed(const Duration(microseconds: 100));
    }

    _engine.stdin = 'uci';

    await _setupNnue();

    _state = EngineState.ready;
  }

  Future<void> applyConfig() async {
    //
    final config = PikafishConfig(LocalData().profile);

    if (!config.ponder) stopPonder();

    _engine.stdin = 'setoption name Threads value ${config.threads}';
    _engine.stdin = 'setoption name Hash value ${config.hashSize}';
    _engine.stdin = 'setoption name Ponder value ${config.ponder}';
    _engine.stdin = 'setoption name Skill Level value ${config.level}';
  }

  Future<bool> go(Position position, EngineCallback callback) async {
    //
    this.callback = callback;

    final pos = position.lastCapturedPosition;
    final moves = position.movesAfterLastCaptured;

    var uciPos = 'position fen $pos', uciGo = '';
    if (moves != '') uciPos += ' moves $moves';

    var timeLimit = PikafishConfig(LocalData().profile).timeLimit;
    if (timeLimit <= 90) timeLimit *= 1000;
    uciGo = 'go movetime $timeLimit';

    _state = EngineState.searching;

    _engine.stdin = uciPos;
    _engine.stdin = uciGo;

    return true;
  }

  Future<bool> goPonder(
      Position position, EngineCallback callback, String ponder) async {
    //
    this.callback = callback;

    final pos = position.lastCapturedPosition;
    final moves = position.movesAfterLastCaptured;

    var uciPos = 'position fen $pos', uciGo = '';
    if (moves != '') uciPos += ' moves $moves';

    if (moves == '') uciPos += ' moves ';

    uciPos += ' $ponder';
    uciGo = 'go ponder infinite';

    _state = EngineState.pondering;

    _engine.stdin = uciPos;
    _engine.stdin = uciGo;

    return true;
  }

  Future<bool> goHint(Position position, EngineCallback callback) async {
    //
    final result = go(position, callback);
    _state = EngineState.hinting;

    return result;
  }

  Future<void> ponderhit() async {
    //
    _engine.stdin = 'ponderhit';
    _state = EngineState.searching;

    final timeLimit = PikafishConfig(LocalData().profile).timeLimit;

    await Future.delayed(
      Duration(seconds: timeLimit),
      () => _engine.stdin = 'stop',
    );
  }

  Future<void> stopPonder() async {
    //
    if (_state == EngineState.pondering) {
      callback = null;
      _engine.stdin = 'stop';
    }

    _state = EngineState.ready;
  }

  Future<void> shutdown() async {
    _engine.dispose();
    _subscription.cancel();
    _state = EngineState.unknown;
  }

  _setupEngine() {
    _engine = Pikafish();
    _subscriber();
  }

  void _subscriber() {
    //
    _subscription = _engine.stdout.listen((line) {
      //
      prt('engine=> $line');
      if (callback == null) return;

      if (line.startsWith('info')) {
        callback!(EngineResponse(EngineType.pikafish, EngineInfo.parse(line)));
      } else if (line.startsWith('bestmove')) {
        callback!(EngineResponse(EngineType.pikafish, Bestmove.parse(line)));
        _state = EngineState.ready;
      } else if (line.startsWith('nobestmove')) {
        callback!(EngineResponse(EngineType.pikafish, NoBestmove()));
        _state = EngineState.ready;
      }
    });
  }

  _setupNnue() async {
    //
    final appDocDir = await getApplicationDocumentsDirectory();
    final nnueFile = File('${appDocDir.path}/pikafish.nnue');

    if (!(await nnueFile.exists())) {
      await nnueFile.create(recursive: true);
      final bytes = await rootBundle.load('assets/pikafish.nnue');
      await nnueFile.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    }

    _engine.stdin = 'setoption name EvalFile value ${nnueFile.path}';
  }

  void newGame() {
    //
    if (_state == EngineState.searching || _state == EngineState.pondering) {
      _engine.stdin = 'stop';
    }

    _engine.stdin = 'ucinewgame';
    _state = EngineState.ready;
  }

  EngineState get state => _state;
}
