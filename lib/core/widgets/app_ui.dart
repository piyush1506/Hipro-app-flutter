import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme/app_colors.dart';

class HiproMark extends StatelessWidget {
  const HiproMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(compact ? 11 : 13),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            Icons.home_repair_service_rounded,
            color: Colors.white,
            size: compact ? 19 : 22,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 11),
          const Text(
            'HIPRO',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          icon: Icon(icon, size: 20),
        ),
        if (badge)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 32),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, height: 1.45),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wraps any widget with a tactile press animation.
///
/// Gives cards and list rows the "physical" feedback a native app should
/// have, without having to hand-roll a stateful widget at every call site.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          borderRadius: widget.borderRadius,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}

/// The standard Hipro surface card.
///
/// Flat grey borders everywhere make the app feel dated, so cards use a soft
/// elevation that grows while the card is being pressed.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 18,
    this.color,
    this.borderColor,
    this.elevated = false,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final bool elevated;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final hasGradient = widget.gradient != null;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: widget.padding,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: hasGradient ? null : (widget.color ?? AppColors.surface),
            gradient: widget.gradient,
            borderRadius: radius,
            border: Border.all(
              color: widget.borderColor ??
                  (hasGradient
                      ? Colors.white.withValues(alpha: 0.20)
                      : AppColors.borderSubtle),
            ),
            boxShadow: _pressed
                ? AppShadows.lift
                : (widget.elevated ? AppShadows.md : AppShadows.xs),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Rounded gradient tile used for service / category icons.
class GradientIconTile extends StatelessWidget {
  const GradientIconTile({
    super.key,
    this.icon,
    this.size = 44,
    this.iconSize,
    this.gradient,
    this.background,
    this.iconColor,
    this.borderRadius,
    this.child,
    this.shadow = false,
  });

  final IconData? icon;
  final double size;
  final double? iconSize;
  final Gradient? gradient;
  final Color? background;
  final Color? iconColor;
  final double? borderRadius;
  final Widget? child;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? size * 0.32);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient == null ? (background ?? AppColors.primary) : null,
        gradient: gradient,
        borderRadius: radius,
        boxShadow: shadow ? AppShadows.glow(AppColors.primary) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child ??
          (icon != null
              ? Icon(
                  icon,
                  color: iconColor ?? Colors.white,
                  size: iconSize ?? size * 0.46,
                )
              : const SizedBox.shrink()),
    );
  }
}

/// Shimmering placeholder used while content is loading.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Rounded search input with a clear affordance.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search services...',
    this.onClear,
    this.autofocus = false,
    this.prefixIcon = Icons.search_rounded,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;
  final bool autofocus;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              splashRadius: 18,
              onPressed: onClear,
            );
          },
        ),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

/// Compact KPI tile used on dashboards and summary strips.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.primary,
    this.gradient,
    this.caption,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final Gradient? gradient;
  final String? caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientIconTile(
              icon: icon,
              size: 30,
              iconSize: 16,
              gradient: gradient,
              background: color.withValues(alpha: 0.12),
              iconColor: color,
              borderRadius: 10,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 6),
              Text(
                caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small pill used for statuses, filters and metadata.
class PillLabel extends StatelessWidget {
  const PillLabel({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: filled ? Colors.white : color, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AppToast {
  static OverlayEntry? _currentEntry;

  static void hide() {
    if (_currentEntry != null && _currentEntry!.mounted) {
      _currentEntry?.remove();
    }
    _currentEntry = null;
  }

  static void showChatNotification(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTapChat,
  }) {
    show(
      context,
      title: title,
      message: message,
      actionLabel: 'Reply',
      onAction: onTapChat,
      onTap: onTapChat,
      duration: const Duration(seconds: 6),
      isChat: true,
    );
  }

  static void show(
    BuildContext context, {
    String? title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onTap,
    bool isError = false,
    bool isChat = false,
    Duration duration = const Duration(milliseconds: 1400),
  }) {
    // 1. Remove previous toast if any
    hide();

    // 2. Clean diagnostic / technical error strings
    final formattedMessage = isError ? cleanErrorMessage(message) : message;

    String? displayTitle = title;
    String displayBody = formattedMessage;
    if (displayTitle == null && displayBody.contains('\n')) {
      final parts = displayBody.split('\n');
      displayTitle = parts.first.trim();
      displayBody = parts.sublist(1).join('\n').trim();
    }

    // 3. Always show top-positioned floating overlay toast (1 to 1.5 seconds)
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) {
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (ctx) => _ToastOverlayWidget(
          title: displayTitle,
          message: displayBody,
          actionLabel: actionLabel,
          onAction: onAction,
          onTap: onTap,
          isError: isError,
          isChat: isChat,
          duration: duration,
          onDismiss: () {
            if (entry.mounted) {
              entry.remove();
            }
            if (_currentEntry == entry) {
              _currentEntry = null;
            }
          },
        ),
      );

      _currentEntry = entry;
      overlay.insert(entry);
      return;
    }

    // Fallback only if no overlay found in widget tree
    final scaffold = ScaffoldMessenger.maybeOf(context);
    if (scaffold != null) {
      scaffold.clearSnackBars();
      scaffold.showSnackBar(
        SnackBar(
          elevation: 5,
          backgroundColor: isError ? const Color(0xFFFEF2F2) : Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isError ? const Color(0xFFFECACA) : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          duration: duration,
          content: InkWell(
            onTap: onTap != null
                ? () {
                    scaffold.hideCurrentSnackBar();
                    onTap();
                  }
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isError
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : const Color(0xFF1864E8).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : (isChat ? Icons.chat_bubble_rounded : Icons.check_circle_outline_rounded),
                    color: isError ? const Color(0xFFDC2626) : const Color(0xFF1864E8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayTitle != null && displayTitle.isNotEmpty) ...[
                        Text(
                          displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        displayBody,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF334155),
                          fontSize: 12,
                          fontWeight: displayTitle != null ? FontWeight.w500 : FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(width: 10),
                  Material(
                    color: const Color(0xFF1864E8),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        scaffold.hideCurrentSnackBar();
                        onAction();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Cleans raw Dio / HTTP / socket error messages into user-friendly text
  static String cleanErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred.';
    final str = error.toString().trim();
    if (str.isEmpty) return 'An unexpected error occurred.';

    String prefix = '';
    String content = str;
    if (str.contains(': ')) {
      final colonIndex = str.indexOf(': ');
      final possiblePrefix = str.substring(0, colonIndex).trim();
      if (!possiblePrefix.contains('DioException') && !possiblePrefix.contains('Exception')) {
        prefix = '$possiblePrefix: ';
        content = str.substring(colonIndex + 2).trim();
      }
    }

    if (content.contains('status code of 404') || content.contains('404 Not Found') || content.contains('status 404')) {
      return '${prefix}Service temporarily unavailable (404). Please try again shortly.';
    }
    if (content.contains('status code of 500') || content.contains('status code of 502') || content.contains('status code of 503')) {
      return '${prefix}Server error occurred. Please try again in a few moments.';
    }
    if (content.contains('status code of 401') || content.contains('status code of 403')) {
      return '${prefix}Session expired. Please log in again to continue.';
    }
    if (content.contains('SocketException') ||
        content.contains('Failed host lookup') ||
        content.contains('Network is unreachable') ||
        content.contains('connection refused') ||
        content.contains('connectTimeout') ||
        content.contains('receiveTimeout')) {
      return '${prefix}Network error. Please check your internet connection.';
    }

    if (content.startsWith('Exception: ')) {
      content = content.substring('Exception: '.length);
    }
    if (content.length > 150) {
      content = '${content.substring(0, 147)}...';
    }

    return '$prefix$content';
  }
}

class _ToastOverlayWidget extends StatefulWidget {
  final String? title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;
  final bool isError;
  final bool isChat;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlayWidget({
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onTap,
    this.isError = false,
    this.isChat = false,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlayWidget> createState() => _ToastOverlayWidgetState();
}

class _ToastOverlayWidgetState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    if (!mounted) {
      widget.onDismiss();
      return;
    }
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Respect device notch / dynamic island / status bar safely
    final topPadding = mediaQuery.padding.top + 8;

    return Positioned(
      top: topPadding,
      left: 14,
      right: 14,
      child: Material(
        type: MaterialType.transparency,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap != null
                  ? () {
                      _dismiss();
                      widget.onTap!();
                    }
                  : null,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -3) {
                  _dismiss();
                }
              },
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isError
                      ? const Color(0xFFFEF2F2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isError
                        ? const Color(0xFFFECACA)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.isError
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : const Color(0xFF1864E8).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isError
                            ? Icons.error_outline_rounded
                            : (widget.isChat
                                ? Icons.chat_bubble_rounded
                                : Icons.check_circle_outline_rounded),
                        color: widget.isError
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF1864E8),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null && widget.title!.isNotEmpty) ...[
                            Text(
                              widget.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A), // Deep Slate-900 (High contrast bold text)
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            widget.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF334155), // Charcoal slate-700 (Crisp & readable)
                              fontSize: 12,
                              fontWeight: widget.title != null ? FontWeight.w500 : FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.actionLabel != null && widget.onAction != null) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: const Color(0xFF1864E8),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            _dismiss();
                            widget.onAction!();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            child: Text(
                              widget.actionLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _dismiss,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

