import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:smarttask/core/extensions/context_extensions.dart';

class MainBottomDriverNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomDriverNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedHome02,
                HugeIcons.strokeRoundedHome02,
                'Home',
                0,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedAbacus,
                HugeIcons.strokeRoundedAbacus,
                'My Request',
                1,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedAbacus,
                HugeIcons.strokeRoundedAbacus,
                'Orders',
                2,
              ),
              _buildNavItem(
                context,
                HugeIcons.strokeRoundedAbacus,
                HugeIcons.strokeRoundedAbacus,
                'Profile',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected
                      ? context.theme.primaryColor
                      : context.theme.unselectedWidgetColor,
                  key: ValueKey(isSelected),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? context.theme.primaryColor
                      : context.theme.unselectedWidgetColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
