import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomNumberKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final bool useBackspace;
  final bool animate;
  final Color? textColor;
  final double? fontSize;
  final double? bottomPadding;

  const CustomNumberKeyboard({
    super.key,
    required this.onKeyPressed,
    this.useBackspace = true,
    this.animate = true,
    this.textColor,
    this.fontSize,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding ?? 0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = constraints.maxWidth / 3;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: buttonSize / (buttonSize * 0.5),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final keys = [
                '1',
                '2',
                '3',
                '4',
                '5',
                '6',
                '7',
                '8',
                '9',
                '.',
                '0',
                useBackspace ? '⌫' : 'clear'
              ];
              Widget keyWidget = Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onKeyPressed(keys[index]),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: keys[index] == '⌫' || keys[index] == 'clear'
                        ? Icon(
                            Icons.backspace_outlined,
                            color: Colors.black54,
                            size: fontSize ?? 20,
                          )
                        : Text(
                            keys[index],
                            style: GoogleFonts.outfit(
                              fontSize: fontSize ?? 20,
                              fontWeight: FontWeight.w500,
                              color: textColor ??
                                  (keys[index] == '⌫'
                                      ? Colors.black54
                                      : Colors.black87),
                            ),
                          ),
                  ),
                ),
              );

              if (animate) {
                keyWidget = keyWidget.animate().fadeIn(
                      duration: 400.ms,
                      delay: (50 * index).ms,
                    );
              }

              return keyWidget;
            },
          );
        },
      ),
    );
  }
}
