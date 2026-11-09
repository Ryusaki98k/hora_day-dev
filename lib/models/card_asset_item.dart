import 'package:flutter/material.dart';

enum CardAssetType {
  icon,
  emoji,
  text,
  seal,
  svg,
}

class CardAssetItem {
  final String id;
  CardAssetType type;
  Offset position;
  double scale;
  double rotation; // Radians

  // Icon specific
  IconData? icon;

  // Emoji or text specific
  String text;

  // Seal / badge specific
  String? subtitle;
  IconData? sealIcon;

  // SVG specific
  String? svgContent;
  String? svgAssetKey; // key สำหรับโหลดจาก assets/

  // Styling
  Color? color;
  double fontSize;
  bool isBold;

  CardAssetItem({
    required this.id,
    required this.type,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.icon,
    this.text = '',
    this.subtitle,
    this.sealIcon,
    this.svgContent,
    this.svgAssetKey,
    this.color,
    this.fontSize = 16.0,
    this.isBold = false,
  });

  CardAssetItem copyWith({
    String? id,
    CardAssetType? type,
    Offset? position,
    double? scale,
    double? rotation,
    IconData? icon,
    String? text,
    String? subtitle,
    IconData? sealIcon,
    String? svgContent,
    String? svgAssetKey,
    Color? color,
    double? fontSize,
    bool? isBold,
  }) {
    return CardAssetItem(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      icon: icon ?? this.icon,
      text: text ?? this.text,
      subtitle: subtitle ?? this.subtitle,
      sealIcon: sealIcon ?? this.sealIcon,
      svgContent: svgContent ?? this.svgContent,
      svgAssetKey: svgAssetKey ?? this.svgAssetKey,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      isBold: isBold ?? this.isBold,
    );
  }
}
