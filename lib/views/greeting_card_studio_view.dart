import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_asset_item.dart';
import '../models/card_element_style.dart';
import '../models/card_theme_style.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/app_colors.dart';
import '../utils/card_saver.dart';
import '../utils/thai_date_helper.dart';
import '../widgets/card_asset_property_bar.dart';
import '../widgets/greeting_card_studio/card_theme_config.dart';
import '../widgets/greeting_card_studio/greeting_card_canvas.dart';
import '../widgets/greeting_card_studio/studio_action_buttons.dart';
import '../widgets/greeting_card_studio/studio_canva_controls.dart';
import '../widgets/greeting_card_studio/studio_download_dialog.dart';
import '../widgets/greeting_card_studio/studio_form_controls.dart';
import '../widgets/greeting_card_studio/studio_internal_property_bar.dart';

export '../models/card_element_style.dart';
export '../models/card_theme_style.dart';

/// หน้าสตูดิโอออกแบบการ์ดอวยพรวันเกิดมงคล
/// (Auspicious Birthday Greeting Card Studio)
/// ผู้ใช้สามารถเลือกลูกดวงหรือพิมพ์ชื่อเอง เลือกธีมการ์ด ปรับแต่งคำอวยพร
/// พรีวิวแบบ Real-time และดาวน์โหลดการ์ดความละเอียดสูง (HD) บันทึกลงเครื่อง
class GreetingCardStudioView extends StatefulWidget {
  final CustomerService customerService;
  final Customer? initialCustomer;

  const GreetingCardStudioView({
    super.key,
    required this.customerService,
    this.initialCustomer,
  });

  @override
  State<GreetingCardStudioView> createState() => _GreetingCardStudioViewState();
}

class _GreetingCardStudioViewState extends State<GreetingCardStudioView> {
  final GlobalKey _cardRepaintKey = GlobalKey();

  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  late TextEditingController _blessingController;
  late TextEditingController _signatureController;

  CardThemeStyle _selectedTheme = CardThemeStyle.celestialGold;
  Customer? _selectedCustomer;
  bool _showAge = true;
  bool _showDayOfWeek = true;
  bool _isDownloading = false;

  int _selectedBlessingCategory = 0;
  int _activeStudioTab = 0; // 0 = ข้อมูล & ธีม, 1 = คลังตกแต่ง Canva

  // Canva Assets Layer
  final List<CardAssetItem> _assets = [];
  String? _selectedAssetId;

  // Internal Card Elements Canva Styles (ลากวาง ปรับขนาด หมุน เปลี่ยนสี ภายในตัวการ์ด)
  final Map<String, CardElementStyle> _elementStyles = {
    'top_badge': CardElementStyle(),
    'recipient_name': CardElementStyle(),
    'meta_chips': CardElementStyle(),
    'separator': CardElementStyle(),
    'blessing_box': CardElementStyle(),
    'signature': CardElementStyle(),
    'footer': CardElementStyle(),
  };
  String? _selectedElementId;

  CardAssetItem? get _selectedAsset {
    if (_selectedAssetId == null) return null;
    final idx = _assets.indexWhere((a) => a.id == _selectedAssetId);
    return idx != -1 ? _assets[idx] : null;
  }

  final List<Map<String, String>> _blessingTemplates = [
    {
      'title': 'โชคลาภ & เงินทอง',
      'svg':
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M14.8 9A2 2 0 0 0 13 8h-2a2 2 0 1 0 0 4h2a2 2 0 1 1 0 4h-2a2 2 0 0 1-1.8-1"/><path d="M12 6v2m0 8v2"/></svg>',
      'text':
          'สุขสันต์วันเกิด ขออำนาจบารมีและสิ่งศักดิ์สิทธิ์ดลบันดาลให้มีแต่โชคลาภ เงินทองไหลมาเทมาไม่ขาดสาย หยิบจับสิ่งใดเป็นเงินเป็นทอง ดวงชะตารุ่งโรจน์ มั่งคั่งร่ำรวยตลอดทั้งปี',
    },
    {
      'title': 'การงาน & บารมี',
      'svg':
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="14" x="2" y="7" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>',
      'text':
          'สุขสันต์วันเกิด ขอให้หน้าที่การงานเจริญก้าวหน้า มีชื่อเสียงบารมี ผู้ใหญ่เมตตาอุปถัมภ์ ปัญหาอุปสรรคใดๆ คลี่คลาย สำเร็จสมหวังในทุกเป้าหมายที่ตั้งใจ',
    },
    {
      'title': 'สุขภาพ & อายุวัฒนะ',
      'svg':
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/></svg>',
      'text':
          'สุขสันต์วันเกิด ขออวยพรให้มีสุขภาพร่างกายแข็งแรง ปราศจากโรคภัยไข้เจ็บ จิตใจผ่องใสสงบ มีแต่รอยยิ้ม ความอบอุ่น และความสุขรายล้อมในทุกๆ วัน',
    },
    {
      'title': 'เสน่ห์ & เมตตามหานิยม',
      'svg':
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg>',
      'text':
          'สุขสันต์วันเกิด ขอให้มีเสน่ห์เมตตามหานิยม ไปที่ใดก็มีคนรักใคร่เอ็นดู ความรักสุขสมหวัง พบเจอแต่กัลยาณมิตรที่ดี เกื้อหนุนนำพาชีวิตไปสู่ความเจริญรุ่งเรือง',
    },
    {
      'title': 'ศิริมงคล & แคล้วคลาด',
      'svg':
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/><path d="M5 3v4"/><path d="M3 5h4"/><path d="M19 17v4"/><path d="M17 19h4"/></svg>',
      'text':
          'สุขสันต์วันคล้ายวันเกิด น้อมอาราธนาคุณพระศรีรัตนตรัยและสิ่งศักดิ์สิทธิ์ คุ้มครองรักษาให้แคล้วคลาดปลอดภัยจากภยันตรายทั้งปวง มีดวงชะตาที่สว่างไสว ปลอดโปร่ง ร่มเย็นเป็นสุขสถาพร',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize TextEditingControllers with appropriate default values
    _nameController = TextEditingController();
    _nicknameController = TextEditingController();
    _ageController = TextEditingController();
    _blessingController = TextEditingController();
    _signatureController = TextEditingController();

    _selectedCustomer = widget.initialCustomer ??
        (widget.customerService.todayBirthdayCustomers.isNotEmpty
            ? widget.customerService.todayBirthdayCustomers.first
            : (widget.customerService.upcomingBirthdayCustomers.isNotEmpty
                ? widget.customerService.upcomingBirthdayCustomers.first
                : (widget.customerService.customers.isNotEmpty
                    ? widget.customerService.customers.first
                    : null)));

    // Populate controller values based on selected customer or defaults
    if (_selectedCustomer != null) {
      _nameController.text = _selectedCustomer!.fullName;
      _nicknameController.text = _selectedCustomer!.nickname;
      _ageController.text = _selectedCustomer!.turningAge.toString();
    } else {
      _nameController.text = 'คุณดวงใจ สิริมงคล';
      _nicknameController.text = 'ดวง';
      _ageController.text = '35';
    }
    _blessingController.text = _blessingTemplates[0]['text']!;
    _signatureController.text = 'ด้วยความปรารถนาดี จากอาจารย์หมอดูประจำตัว';

    // Initialize preset map
    _initializePresets();
  }

  // Preset definitions
  late final Map<String, List<CardAssetItem>> _presetMap;
  void _initializePresets() {
    _presetMap = {
      'default': [
        CardAssetItem(
          id: 'seal_default',
          type: CardAssetType.seal,
          text: 'มงคลโชคลาภ',
          subtitle: 'ดวงสิริมงคล',
          sealIcon: Icons.verified_rounded,
          position: const Offset(230, 48),
          scale: 0.95,
          color: const Color(0xFFD4AF37),
        ),
        CardAssetItem(
          id: 'decor_sparkle',
          type: CardAssetType.icon,
          icon: Icons.auto_awesome,
          text: '',
          position: const Offset(42, 62),
          scale: 1.1,
          color: const Color(0xFFD4AF37),
        ),
      ],
      'celebration': [
        CardAssetItem(
          id: 'seal_celebration',
          type: CardAssetType.seal,
          text: 'สุขสันต์วันเกิด',
          subtitle: 'ขอให้มีความสุข',
          sealIcon: Icons.cake_rounded,
          position: const Offset(200, 50),
          scale: 1.0,
          color: const Color(0xFFEAB308),
        ),
        CardAssetItem(
          id: 'icon_balloon',
          type: CardAssetType.icon,
          icon: Icons.emoji_events_rounded,
          position: const Offset(80, 120),
          scale: 1.2,
          color: const Color(0xFF10B981),
        ),
        CardAssetItem(
          id: 'text_happy',
          type: CardAssetType.text,
          position: const Offset(110, 260),
          text: 'Happy Birthday!',
          fontSize: 18.0,
          isBold: true,
          color: const Color(0xFF78450A),
        ),
      ],
    };
  }

  void _applyPresetAssets() {
    // Show preset selection dialog
    _showPresetSelectionDialog();
  }

  void _showPresetSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เลือก Preset'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _presetMap.keys.map((name) {
                return ListTile(
                  title: Text(name.isNotEmpty ? '${name[0].toUpperCase()}${name.substring(1)}' : ''),
                  onTap: () => Navigator.of(context).pop(name),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    if (selected != null && _presetMap.containsKey(selected)) {
      setState(() {
        _assets.clear();
        _assets.addAll(_presetMap[selected]!);
        _selectedAssetId = null;
      });
    }
  }

  // Removed StringCasingExtension; capitalization handled inline.



// Duplicate _applyPresetAssets removed; using dialog version above.

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _blessingController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _onCustomerSelected(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      if (customer != null) {
        _nameController.text = customer.fullName.isNotEmpty
            ? customer.fullName
            : customer.displayName;
        _nicknameController.text = customer.nickname;
        _ageController.text = customer.turningAge.toString();
      }
    });
  }

  void _selectBlessingTemplate(int index) {
    setState(() {
      _selectedBlessingCategory = index;
      _blessingController.text = _blessingTemplates[index]['text']!;
    });
  }

  Color _getDayColor() {
    final weekday = _selectedCustomer?.birthDate.weekday ?? DateTime.now().weekday;
    return AppColors.getDayColor(weekday);
  }

  String _getDayName() {
    final weekday = _selectedCustomer?.birthDate.weekday ?? DateTime.now().weekday;
    return ThaiDateHelper.dayOfWeekName(weekday);
  }

  String _getFormattedBlessingText() {
    final name = _nicknameController.text.trim().isNotEmpty
        ? _nicknameController.text.trim()
        : _nameController.text.trim();
    return '✦ สุขสันต์วันเกิด คุณ$name ✦\n\n'
        '${_blessingController.text.trim()}\n\n'
        '${_signatureController.text.trim()}';
  }

  void _copyBlessingText() {
    Clipboard.setData(ClipboardData(text: _getFormattedBlessingText()));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('คัดลอกข้อความอวยพรแล้ว วางส่งในแชทได้ทันที'),
          ],
        ),
        backgroundColor: AppColors.caramelBronze,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _captureAndDownloadCard() async {
    if (_isDownloading) return;
    setState(() {
      _isDownloading = true;
      _selectedAssetId = null;
      _selectedElementId = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _cardRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('ไม่สามารถเข้าถึงพื้นที่การ์ดได้');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('แปลงข้อมูลภาพล้มเหลว');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final cleanName = _nicknameController.text.trim().isNotEmpty
          ? _nicknameController.text.trim()
          : _nameController.text.trim().replaceAll(RegExp(r'\s+'), '_');

      final filename =
          'HoraDay_HBD_${cleanName}_${DateTime.now().millisecondsSinceEpoch}.png';

      final savedResult = await CardSaver.saveImage(
        bytes: pngBytes,
        filename: filename,
      );

      if (!mounted) return;

      StudioDownloadSuccessDialog.show(
        context,
        pathOrNotice: savedResult,
        filename: filename,
        selectedCustomer: _selectedCustomer,
        formattedBlessingText: _getFormattedBlessingText(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการดาวน์โหลด: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Widget _buildCardPreviewWithPropertyBar() {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          margin: const EdgeInsets.only(bottom: 12),
          child: _selectedElementId != null && !_isDownloading
              ? StudioInternalPropertyBar(
                  elementId: _selectedElementId!,
                  style: _elementStyles[_selectedElementId!]!,
                  label: StudioCanvaAssetControls.getElementLabel(_selectedElementId!),
                  onReset: () => setState(() => _elementStyles[_selectedElementId!]!.reset()),
                  onDone: () => setState(() => _selectedElementId = null),
                  onScaleChanged: (val) => setState(() => _elementStyles[_selectedElementId!]!.scale = val),
                  onRotationDelta: (delta) => setState(() => _elementStyles[_selectedElementId!]!.rotation += delta),
                  onColorChanged: (c) => setState(() => _elementStyles[_selectedElementId!]!.color = c),
                )
              : (_selectedAsset != null && !_isDownloading
                  ? CardAssetPropertyBar(
                      selectedItem: _selectedAsset!,
                      onUpdateItem: (updated) {
                        setState(() {
                          final idx = _assets.indexWhere((a) => a.id == updated.id);
                          if (idx != -1) _assets[idx] = updated;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _assets.removeWhere((a) => a.id == _selectedAssetId);
                          _selectedAssetId = null;
                        });
                      },
                      onDuplicate: () {
                        final current = _selectedAsset!;
                        final newItem = current.copyWith(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          position: Offset(
                            (current.position.dx + 20).clamp(0.0, 300.0),
                            (current.position.dy + 20).clamp(0.0, 480.0),
                          ),
                        );
                        setState(() {
                          _assets.add(newItem);
                          _selectedAssetId = newItem.id;
                        });
                      },
                      onBringToFront: () {
                        final current = _selectedAsset!;
                        setState(() {
                          _assets.removeWhere((a) => a.id == current.id);
                          _assets.add(current);
                        });
                      },
                      onDeselect: () {
                        setState(() => _selectedAssetId = null);
                      },
                    )
                  : const StudioIdleToolbarHint()),
        ),
        GreetingCardCanvas(
          cardRepaintKey: _cardRepaintKey,
          themeConfig: CardThemeConfig(
            style: _selectedTheme,
            dayColor: _getDayColor(),
          ),
          elementStyles: _elementStyles,
          selectedElementId: _selectedElementId,
          selectedAssetId: _selectedAssetId,
          isDownloading: _isDownloading,
          nickname: _nicknameController.text.trim(),
          name: _nameController.text.trim(),
          dayName: _getDayName(),
          age: _ageController.text.trim(),
          showDayOfWeek: _showDayOfWeek,
          showAge: _showAge,
          blessing: _blessingController.text.trim(),
          signature: _signatureController.text.trim(),
          assets: _assets,
          onTapOutside: () {
            if (_selectedAssetId != null || _selectedElementId != null) {
              setState(() {
                _selectedAssetId = null;
                _selectedElementId = null;
              });
            }
          },
          onSelectElement: (id) {
            setState(() {
              _selectedElementId = id;
              _selectedAssetId = null;
            });
          },
          onSelectAsset: (id) {
            setState(() {
              _selectedAssetId = id;
              _selectedElementId = null;
            });
          },
          onPanElement: (id, delta) {
            setState(() {
              _selectedElementId = id;
              _selectedAssetId = null;
              _elementStyles[id]!.offset += delta;
            });
          },

          onPanAsset: (id, delta) {
            setState(() {
              _selectedAssetId = id;
              _selectedElementId = null;
              final idx = _assets.indexWhere((a) => a.id == id);
              if (idx != -1) {
                final item = _assets[idx];
                item.position = Offset(
                  (item.position.dx + delta.dx).clamp(0.0, 310.0),
                  (item.position.dy + delta.dy).clamp(0.0, 560.0),
                );
              }
            });
          },
          onScaleAsset: (id, scale) {
            setState(() {
              final idx = _assets.indexWhere((a) => a.id == id);
              if (idx != -1) {
                _assets[idx].scale = scale.clamp(0.5, 3.0);
              }
            });
          },
          onRotateAsset: (id, rotation) {
            setState(() {
              final idx = _assets.indexWhere((a) => a.id == id);
              if (idx != -1) {
                _assets[idx].rotation = rotation;
              }
            });
          },
          onDeleteAsset: (id) {
            setState(() {
              _assets.removeWhere((a) => a.id == id);
              if (_selectedAssetId == id) _selectedAssetId = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomizationControls(List<Customer> customers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFF1EBE1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeStudioTab = 0),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: _activeStudioTab == 0 ? context.goldColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: _activeStudioTab == 0 ? Colors.white : context.textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '1. ข้อมูล & คำอวยพร',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeStudioTab == 0 ? Colors.white : context.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _activeStudioTab = 1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: _activeStudioTab == 1 ? context.goldColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: _activeStudioTab == 1 ? Colors.white : context.textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '2. คลังตกแต่ง Canva (${_assets.length})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeStudioTab == 1 ? Colors.white : context.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_activeStudioTab == 0)
          StudioFormControls(
            customers: customers,
            selectedCustomer: _selectedCustomer,
            nameController: _nameController,
            nicknameController: _nicknameController,
            ageController: _ageController,
            blessingController: _blessingController,
            signatureController: _signatureController,
            selectedTheme: _selectedTheme,
            dayColor: _getDayColor(),
            dayName: _getDayName(),
            showAge: _showAge,
            showDayOfWeek: _showDayOfWeek,
            selectedBlessingCategory: _selectedBlessingCategory,
            blessingTemplates: _blessingTemplates,
            onCustomerSelected: _onCustomerSelected,
            onThemeSelected: (style) => setState(() => _selectedTheme = style),
            onBlessingCategorySelected: _selectBlessingTemplate,
            onToggleShowAge: (val) => setState(() => _showAge = val),
            onToggleShowDayOfWeek: (val) => setState(() => _showDayOfWeek = val),
            onSwitchToCanvaTab: () => setState(() => _activeStudioTab = 1),
          )
        else
          StudioCanvaAssetControls(
            elementStyles: _elementStyles,
            selectedElementId: _selectedElementId,
            selectedAssetId: _selectedAssetId,
            assets: _assets,
            onSelectElement: (id) {
              setState(() {
                _selectedElementId = id;
                _selectedAssetId = null;
              });
            },
            onResetAllElements: () {
              setState(() {
                for (var s in _elementStyles.values) {
                  s.reset();
                }
                _selectedElementId = null;
              });
            },
            onAddAsset: (item) {
              setState(() {
                _assets.add(item);
                _selectedAssetId = item.id;
                _selectedElementId = null;
              });
            },
            onClearAllAssets: () {
              setState(() {
                _assets.clear();
                _selectedAssetId = null;
              });
            },
            onApplyPreset: _applyPresetAssets,
            onSelectAsset: (id) {
              setState(() {
                _selectedAssetId = id;
                _selectedElementId = null;
              });
            },
            onDeleteAsset: (id) {
              setState(() {
                _assets.removeWhere((a) => a.id == id);
                if (_selectedAssetId == id) _selectedAssetId = null;
              });
            },
            onReorderAssets: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _assets.removeAt(oldIndex);
                _assets.insert(newIndex, item);
              });
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = widget.customerService.customers;

    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'สตูดิโอการ์ดอวยพรมงคล',
                style: GoogleFonts.prompt(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                'ออกแบบการ์ดวันเกิด • ใส่ชื่อ & คำอวยพร • ดาวน์โหลดลงเครื่อง',
                style: GoogleFonts.sarabun(
                  fontSize: 11,
                  color: context.subTextColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        actions: [
          const AppThemeToggleButton(compact: true),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'คัดลอกข้อความ',
            icon: const Icon(Icons.copy_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
            onPressed: _copyBlessingText,
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _captureAndDownloadCard,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 16),
              label: Text(
                _isDownloading ? 'กำลังโหลด...' : 'ดาวน์โหลด',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.goldColor,
                foregroundColor:
                    context.isDark ? AppColors.celestialVoid : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          children: [
                            _buildCardPreviewWithPropertyBar(),
                            const SizedBox(height: 18),
                            StudioActionButtons(
                              isDownloading: _isDownloading,
                              onDownload: _captureAndDownloadCard,
                              onCopyBlessing: _copyBlessingText,
                              selectedCustomer: _selectedCustomer,
                              formattedBlessingText: _getFormattedBlessingText(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: context.borderColor),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 24, 60),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildCustomizationControls(customers),
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ClipRect(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _buildCardPreviewWithPropertyBar()),
                      const SizedBox(height: 16),
                      StudioActionButtons(
                        isDownloading: _isDownloading,
                        onDownload: _captureAndDownloadCard,
                        onCopyBlessing: _copyBlessingText,
                        selectedCustomer: _selectedCustomer,
                        formattedBlessingText: _getFormattedBlessingText(),
                      ),
                      const SizedBox(height: 24),
                      Divider(thickness: 1, color: context.borderColor),
                      const SizedBox(height: 16),
                      _buildCustomizationControls(customers),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
