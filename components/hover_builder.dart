import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

class HoverBuilder extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const HoverBuilder({super.key, required this.builder});

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) => _onHoverChanged(enabled: true),
      onExit: (PointerExitEvent event) => _onHoverChanged(enabled: false),
      child: widget.builder(_isHovered),
    );
  }

  void _onHoverChanged({required bool enabled}) {
    try {
      setState(() {
        _isHovered = enabled;
      });
    } catch (e) {
      devPrint('HOVER ERROR---->$e');
    }
  }
}
