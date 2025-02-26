import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToast extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const CustomToast({
    Key? key,
    required this.message,
    this.isError = true,
    this.onActionPressed,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759);
    final backgroundColor =
        isError ? const Color(0xFF1C1917) : const Color(0xFF1C1917);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.srcOver,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: baseColor.withOpacity(0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isError
                        ? FluentIcons.error_circle_24_filled
                        : FluentIcons.checkmark_circle_24_filled,
                    color: baseColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      height: 1.3,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (actionLabel != null && onActionPressed != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onActionPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      backgroundColor: baseColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      actionLabel!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: baseColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuint);
  }
}
