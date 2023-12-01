import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
ThemeData themeData(ThemeDataRef ref, Brightness brightness) {
  const seedColor = Colors.blueGrey;

  return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness));
}
