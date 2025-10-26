import 'dart:ui';
import 'package:flutter/material.dart';

class HeaderAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const HeaderAction({required this.icon, required this.label, required this.onTap});
}

/// A safe, crisp gradient header (PreferredSizeWidget).
/// - No opaque overlays
/// - Subtle blur only (transparent child)
/// - Optional bottom fade into page background
class FitFlowHeaderClean extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<HeaderAction> actions;
  final double height;
  final bool centerTitle;

  const FitFlowHeaderClean({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.height = 120,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      child: Stack(
        children: [
          // 1) Brand gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  // Lovable palette: purple → blue
                  Color(0xFF7A4DFF), // ~ HSL(262,83%,58%)
                  Color(0xFF2F7BFF), // ~ HSL(220,90%,56%)
                ],
              ),
            ),
          ),

          // 2) Gentle glassiness – blur + transparent child
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),

          // 3) Content
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title + subtitle
                    Expanded(
                      child: _TitleBlock(
                        title: title,
                        subtitle: subtitle,
                        centered: centerTitle,
                      ),
                    ),
                    // Pill actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions.map((a) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _Pill(a),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4) Subtle bottom fade (to blend into page bg)
          Positioned(
            left: 0, right: 0, bottom: 0, height: 24,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.00),
                      Colors.black.withOpacity(0.06), // tiny shadow-ish fade
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title; final String? subtitle; final bool centered;
  const _TitleBlock({required this.title, this.subtitle, required this.centered});

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    final cross = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross, mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
          textAlign: align,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22,
            shadows: [Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0,1))],
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(subtitle!,
            textAlign: align,
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontWeight: FontWeight.w500, fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final HeaderAction action;
  const _Pill(this.action);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withOpacity(.28)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(action.icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            const Text('',
              style: TextStyle(fontSize: 0), // keeps height stable if you want icon-only
            ),
            Text(action.label,
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
