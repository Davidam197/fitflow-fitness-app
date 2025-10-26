import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass gradient AppBar used across the app.
/// - Rounded bottom
/// - Soft blur (frosted)
/// - Optional subtitle
/// - Pill action buttons (e.g., Import / Create)
class FitFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<HeaderAction> actions;
  final double height;
  final bool centerTitle;

  const FitFlowHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.height = 112,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      child: Stack(
        children: [
          // Gradient background
          Container(
            height: height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B7CFF), Color(0xFF9A6BFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Subtle white tint + blur for the "glass" feel
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: height,
              color: Colors.white.withOpacity(0.06),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment:
                    centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Top row: title + actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!centerTitle)
                        Expanded(
                          child: _TitleBlock(title: title, subtitle: subtitle),
                        )
                      else
                        Expanded(
                          child: Center(
                            child: _TitleBlock(
                              title: title,
                              subtitle: subtitle,
                              centered: true,
                            ),
                          ),
                        ),

                      // Pill actions on the right
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions
                            .map((a) => Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _PillButton(action: a),
                                ))
                            .toList(),
                      ),
                    ],
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

class HeaderAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint; // optional custom tint

  const HeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });
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

class _TitleBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool centered;
  const _TitleBlock({
    required this.title,
    this.subtitle,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: align,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
