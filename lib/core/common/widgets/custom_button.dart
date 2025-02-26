import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomButtonOptions {
  const CustomButtonOptions({
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.gradient,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
    this.boxShadow,
    this.loadingColor,
    this.loadingStrokeWidth = 2.0,
    this.loadingSize = 24.0,
  });

  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
  final List<BoxShadow>? boxShadow;
  final Color? loadingColor;
  final double loadingStrokeWidth;
  final double loadingSize;
}

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.text,
    required this.onPressed,
    required this.options,
    this.icon,
    this.iconData,
    this.trailing,
    this.showLoadingIndicator = false,
    this.child,
  }) : assert(
          text != null || child != null || icon != null || iconData != null,
          'Either text, child, icon, or iconData must be provided',
        );

  final String? text;
  final Widget? icon;
  final Widget? trailing;
  final IconData? iconData;
  final VoidCallback? onPressed;
  final CustomButtonOptions options;
  final bool showLoadingIndicator;
  final Widget? child;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox.square(
        dimension: widget.options.loadingSize,
        child: CircularProgressIndicator(
          strokeWidth: widget.options.loadingStrokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.options.loadingColor ??
                widget.options.textStyle?.color ??
                Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final content = widget.child ??
        Text(
          widget.text!,
          style: widget.options.textStyle,
          overflow: TextOverflow.ellipsis,
        );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: widget.showLoadingIndicator ? _buildLoadingIndicator() : content,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLoadingIndicator) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: widget.options.height,
              width: widget.options.width,
              decoration: widget.options.gradient != null
                  ? BoxDecoration(
                      gradient: widget.options.gradient,
                      borderRadius: widget.options.borderRadius ??
                          BorderRadius.circular(8),
                      boxShadow: widget.options.boxShadow,
                    )
                  : null,
              child: ElevatedButton(
                onPressed:
                    widget.showLoadingIndicator ? null : widget.onPressed,
                style: _buildButtonStyle(),
                child: _buildButtonContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: widget.options.borderRadius ?? BorderRadius.circular(8),
          side: widget.options.borderSide ?? BorderSide.none,
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return widget.options.disabledColor ??
              widget.options.color?.withOpacity(0.6);
        }
        return widget.options.gradient != null
            ? Colors.transparent
            : widget.options.color;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return widget.options.disabledTextColor;
        }
        return widget.options.textStyle?.color;
      }),
      padding: MaterialStateProperty.all(
        widget.options.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevation: MaterialStateProperty.all(widget.options.elevation ?? 0),
    );
  }
}
