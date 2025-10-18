import 'package:flutter/material.dart';

class FFGradientCard extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final EdgeInsets padding;
  const FFGradientCard({
    super.key,
    required this.child,
    this.colors = const [Color(0xFF4F7CFB), Color(0xFF7A5CFF)],
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.last.withOpacity(.16), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: colors.last.withOpacity(.08), blurRadius: 8,  offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class FFIconPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const FFIconPill({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(.16), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: color.withOpacity(.08), blurRadius: 8,  offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}

class FFSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String actionText;
  const FFSectionHeader({super.key, required this.title, this.onAction, this.actionText='View All'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (onAction != null)
          TextButton(onPressed: onAction, child: Text(actionText)),
      ]),
    );
  }
}
