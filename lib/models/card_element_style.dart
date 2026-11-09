import 'package:flutter/material.dart';

/// สไตล์และการจัดตำแหน่งขององค์ประกอบหลักภายในการ์ด (ลากวาง ปรับขนาด หมุน เปลี่ยนสีได้สไตล์ Canva)
class CardElementStyle {
  Offset offset;
  double scale;
  double rotation;
  Color? color;

  CardElementStyle({
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color,
  });

  void reset() {
    offset = Offset.zero;
    scale = 1.0;
    rotation = 0.0;
    color = null;
  }

  bool get isModified =>
      offset != Offset.zero || scale != 1.0 || rotation != 0.0 || color != null;
}
