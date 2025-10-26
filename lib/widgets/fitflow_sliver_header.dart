import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'fitflow_header.dart' show HeaderAction; // reuse the same HeaderAction class

/// Collapsing glass-gradient header for scrollable screens.
/// - Works inside NestedScrollView or CustomScrollView
/// - Pinned, collapses from expandedHeight to toolbarHeight
/// - Rounded bottom, blur, pill actions (Import / Create)
class FitFlowSliverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<HeaderAction> actions;
  final double expandedHeight;   // e.g. 140–180
  final double toolbarHeight;    // collapsed height (standard AppBar height is 56)
  final bool centerTitle;

  const FitFlowSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.expandedHeight = 156,
    this.toolbarHeight = kToolbarHeight,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      // Rounded bottom edge (works in SliverAppBar)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      // Remove title to avoid duplication - handle everything in flexibleSpace
      title: null,
      // Fancy background that expands/collapses
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final t = _collapsePercent(constraints, expandedHeight, toolbarHeight);
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: _HeaderBackground(
              title: title,
              subtitle: subtitle,
              actions: actions,
              centerTitle: centerTitle,
              // Pass collapse factor to fade subtitle and resize spacing
              t: t,
            ),
            // Handle collapsed state properly
            titlePadding: EdgeInsets.zero,
            title: t > 0.5 ? _CollapsedTitleRow(
              title: title,
              actions: actions,
              centerTitle: centerTitle,
            ) : null,
          );
        },
      ),
      // Ensure status-bar content is light
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // 0.0 (expanded) → 1.0 (collapsed)
  double _collapsePercent(BoxConstraints c, double max, double min) {
    final h = c.biggest.height.clamp(min, max);
    if (max == min) return 1.0;
    return 1.0 - ((h - min) / (max - min));
  }
}

class _HeaderBackground extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<HeaderAction> actions;
  final bool centerTitle;
  final double t; // collapse factor

  const _HeaderBackground({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.centerTitle,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    // Interpolate paddings as we collapse
    final topPad = lerpDouble(14, 8, t)!;
    final bottomPad = lerpDouble(16, 8, t)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient base
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B7CFF), Color(0xFF9A6BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glass blur + tint
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.white.withOpacity(0.06)),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPad, 16, bottomPad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title + optional subtitle
                  Expanded(
                    child: _HeaderTitleBlock(
                      title: title,
                      subtitle: subtitle,
                      centered: centerTitle,
                      // fade out subtitle as it collapses
                      subtitleOpacity: (1.0 - t).clamp(0.0, 1.0),
                    ),
                  ),
                  // Pill actions on the right
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions.map((a) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _PillButton(action: a),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedTitleRow extends StatelessWidget {
  final String title;
  final List<HeaderAction> actions;
  final bool centerTitle;

  const _CollapsedTitleRow({
    required this.title,
    required this.actions,
    required this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    // In collapsed state, keep things compact
    return Row(
      children: [
        if (!centerTitle) ...[
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ] else ...[
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: actions.map((a) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _PillButton(action: a),
          )).toList(),
        ),
      ],
    );
  }
}

class _HeaderTitleBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centered;
  final double subtitleOpacity;

  const _HeaderTitleBlock({
    required this.title,
    this.subtitle,
    required this.centered,
    required this.subtitleOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    final cross = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty)
          Opacity(
            opacity: subtitleOpacity,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                subtitle!,
                textAlign: align,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final HeaderAction action;
  const _PillButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.18);
    final border = Colors.white.withOpacity(0.28);
    final tint = action.tint ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: tint),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
