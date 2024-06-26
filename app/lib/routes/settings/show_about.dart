import 'package:chessroad/routes/main_menu/readme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../game/game.dart';
import '../../ui/snack_bar.dart';

showAbout(BuildContext context) async {
  //
  final packageInfo = await PackageInfo.fromPlatform();
  final version = '${packageInfo.version} (${packageInfo.buildNumber})';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text(
        '关于棋路 Lite ',
        style: TextStyle(color: GameColors.primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 5),
          const Text('版本'),
          Text(version),
          const SizedBox(height: 15),
          const Text('QQ 3群（招募中）'),
          Linkify(
            onOpen: (link) {
              Clipboard.setData(const ClipboardData(text: '897145271'));
              showSnackBar('群号已复制！');
            },
            text: 'http://897145271',
          ),
          const Text('QQ 2群'),
          Linkify(
            onOpen: (link) {
              Clipboard.setData(const ClipboardData(text: '179094728'));
              showSnackBar('群号已复制！');
            },
            text: 'http://179094728',
          ),
          const Text('QQ 1群（大群）'),
          Linkify(
            onOpen: (link) {
              Clipboard.setData(const ClipboardData(text: '67220535'));
              showSnackBar('群号已复制！');
            },
            text: 'http://67220535',
          ),
          const SizedBox(height: 15),
          const Text('官网'),
          Linkify(
            onOpen: (link) async => openLink(link.url, context),
            text: 'https://www.mdevs.cn',
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
