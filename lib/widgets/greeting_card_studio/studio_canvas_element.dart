import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/card_asset_item.dart';
import '../../models/card_element_style.dart';

/// ห่อหุ้มองค์ประกอบภายในการ์ดให้สามารถแตะเลือก ลากย้าย ปรับขนาด หมุน และเปลี่ยนสีได้อิสระแบบ Canva
class MovableCardElement extends StatelessWidget {
  final String id;
  final String label;
  final CardElementStyle style;
  final bool isSelected;
  final Widget child;
  final VoidCallback onSelect;
  final ValueChanged<Offset> onPanUpdate;

  const MovableCardElement({
    super.key,
    required this.id,
    required this.label,
    required this.style,
    required this.isSelected,
    required this.child,
    required this.onSelect,
    required this.onPanUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: style.offset,
      child: Transform.rotate(
        angle: style.rotation,
        child: Transform.scale(
          scale: style.scale,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSelect,
            onPanUpdate: (details) => onPanUpdate(details.delta),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.10),
                    )
                  : null,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// วิดเจ็ต Asset ที่ลากวาง ขยาย หมุน ได้สไตล์ Canva
class StudioAssetWidget extends StatefulWidget {
  final CardAssetItem item;
  final bool isSelected;
  final Color accentColor;
  final Color bodyTextColor;
  final VoidCallback onSelect;
  final ValueChanged<Offset> onPanUpdate;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onRotationDelta;
  final VoidCallback onDelete;

  const StudioAssetWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.bodyTextColor,
    required this.onSelect,
    required this.onPanUpdate,
    required this.onScaleChanged,
    required this.onRotationDelta,
    required this.onDelete,
  });

  @override
  State<StudioAssetWidget> createState() => _StudioAssetWidgetState();
}

class _StudioAssetWidgetState extends State<StudioAssetWidget> {
  double _startScale = 1.0;
  double _startRotation = 0.0;

  Widget _renderAssetContent() {
    final item = widget.item;
    switch (item.type) {
      case CardAssetType.emoji:
        return Text(
          item.text,
          style: TextStyle(fontSize: item.fontSize),
        );
      case CardAssetType.icon:
        return Icon(
          item.icon,
          size: 32,
          color: item.color ?? widget.accentColor,
        );
      case CardAssetType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: (item.color ?? const Color(0xFFD4AF37)).withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            item.text,
            style: GoogleFonts.sarabun(
              fontSize: item.fontSize,
              fontWeight: FontWeight.bold,
              color: item.color ?? widget.bodyTextColor,
            ),
          ),
        );
      case CardAssetType.seal:
        final sealColor = item.color ?? widget.accentColor;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFFDF8),
                sealColor.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sealColor, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: sealColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.sealIcon != null) ...[
                Icon(item.sealIcon, size: 16, color: sealColor),
                const SizedBox(width: 5),
              ],
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.text,
                    style: GoogleFonts.prompt(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF78450A),
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty)
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5A534A),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      case CardAssetType.svg:
        if (item.svgAssetKey != null && item.svgAssetKey!.isNotEmpty) {
          return SvgPicture.asset(
            item.svgAssetKey!,
            width: 48,
            height: 48,
            colorFilter: item.color != null
                ? ColorFilter.mode(item.color!, BlendMode.srcIn)
                : null,
          );
        }
        return SvgPicture.string(
          item.svgContent ??
              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/></svg>',
          width: 48,
          height: 48,
          colorFilter: item.color != null
              ? ColorFilter.mode(item.color!, BlendMode.srcIn)
              : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: Transform.rotate(
        angle: item.rotation,
        child: Transform.scale(
          scale: item.scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.isSelected) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDelete,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                    child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ],
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onSelect,
                onScaleStart: (details) {
                  _startScale = item.scale;
                  _startRotation = item.rotation;
                },
                onScaleUpdate: (details) {
                  widget.onPanUpdate(details.focalPointDelta);
                  if (details.pointerCount > 1) {
                    widget.onScaleChanged((_startScale * details.scale).clamp(0.5, 3.0));
                    widget.onRotationDelta(_startRotation + details.rotation);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: widget.isSelected
                      ? BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                        )
                      : null,
                  child: _renderAssetContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
