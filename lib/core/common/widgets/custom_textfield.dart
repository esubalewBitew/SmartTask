import 'package:smarttask/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

typedef SubmitCallback = void Function(String value);

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {super.key,
      this.textInputType,
      this.textInputAction,
      this.initialValue,
      this.maxLength,
      this.overrideValidator = false,
      this.prefixText,
      this.controller,
      this.focusNode,
      this.textAlign,
      this.style,
      this.autofocus,
      this.onTap,
      this.onSubmitted,
      this.borderRadius,
      this.validator,
      this.isEnabled,
      this.labelText,
      this.hintText,
      this.hintStyle,
      this.prefix,
      this.readOnly,
      this.maxLines,
      this.autoValidateMode,
      this.isPassword = false,
      this.onSaved,
      this.prefixIcon,
      this.onChange,
      this.decoration,
      this.inputFormatters,
      this.fillColor,
      this.contentPadding,
      this.suffixIcon,
      this.onSuffixTap,
      this.prefixWidget});

  final EdgeInsetsDirectional? contentPadding;
  final String? hintText;
  final bool overrideValidator;
  final bool? readOnly;
  final String? labelText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  final TextAlign? textAlign;
  final VoidCallback? onSuffixTap;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final SubmitCallback? onSubmitted;
  final String? Function(String?)? validator;
  TextInputAction? textInputAction;
  void Function(String)? onSaved, onChange;
  final String? initialValue;
  final Widget? prefix;
  final Widget? prefixIcon;
  final int? maxLines;
  final double? borderRadius;
  final bool? isEnabled;
  final String? prefixText;
  final bool? autofocus;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color? fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autoValidateMode;
  final InputDecoration? decoration;
  final Widget? prefixWidget;

  TextInputType? textInputType;
  bool isPassword = false;
  OutlineInputBorder formOutlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      width: 0,
      color: Colors.transparent,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus ?? false,
      onTap: onTap,
      style: style ??
          GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
            ),
          ),
      maxLines: isPassword ? 1 : maxLines,
      enabled: isEnabled,
      readOnly: readOnly ?? false,
      textAlign: textAlign ?? TextAlign.start,
      initialValue: initialValue,
      obscureText: isPassword,
      inputFormatters: inputFormatters,
      keyboardType: textInputType,
      validator: overrideValidator
          ? validator
          : (value) {
              if (value == null || value.isEmpty) {
                return "This Field can't be empty";
              }
              return validator?.call(value);
            },
      onSaved: (val) {
        onSaved!(val!);
      },
      onChanged: onChange,
      maxLength: maxLength,
      onFieldSubmitted: onSubmitted,
      focusNode: focusNode,
      controller: controller,
      textInputAction: textInputAction,
      autovalidateMode: autoValidateMode,
      decoration: decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
            counterText: '',
            filled: true,
            prefix: prefixWidget ?? prefix,
            prefixText: prefixText,
            prefixStyle: GoogleFonts.montserrat(
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: context.theme.textTheme.bodyMedium!.color,
              ),
            ),
            prefixIcon: prefixWidget == null ? prefixIcon : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: suffixIcon,
                  )
                : null,
            border: formOutlineBorder,
            labelStyle: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
            hintStyle: hintStyle ??
                GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                  ),
                ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 50),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 50),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 50),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 50),
            ),
            fillColor: Color(0xFFF8F8F8),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          ),
    );
  }

  CustomTextFormField copyWith({
    String? hintText,
    bool? overrideValidator,
    String? labelText,
    TextStyle? style,
    FocusNode? focusNode,
    TextAlign? textAlign,
    TextEditingController? controller,
    SubmitCallback? onSubmitted,
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    void Function(String)? onSaved,
    void Function(String)? onChange,
    String? initialValue,
    Widget? prefix,
    int? maxLines,
    double? borderRadius,
    bool? isEnabled,
    bool? autofocus,
    int? maxLength,
    AutovalidateMode? autoValidateMode,
    TextInputType? textInputType,
    bool? isPassword,
    OutlineInputBorder? formOutlineBorder,
  }) {
    return CustomTextFormField(
      hintText: hintText ?? this.hintText,
      overrideValidator: overrideValidator ?? this.overrideValidator,
      labelText: labelText ?? this.labelText,
      style: style ?? this.style,
      focusNode: focusNode ?? this.focusNode,
      textAlign: textAlign ?? this.textAlign,
      controller: controller ?? this.controller,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      validator: validator ?? this.validator,
      textInputAction: textInputAction ?? this.textInputAction,
      onSaved: onSaved ?? this.onSaved,
      onChange: onChange ?? this.onChange,
      initialValue: initialValue ?? this.initialValue,
      prefix: prefix ?? this.prefix,
      maxLines: maxLines ?? this.maxLines,
      borderRadius: borderRadius ?? this.borderRadius,
      isEnabled: isEnabled ?? this.isEnabled,
      autofocus: autofocus ?? this.autofocus,
      maxLength: maxLength ?? this.maxLength,
      autoValidateMode: autoValidateMode ?? this.autoValidateMode,
      textInputType: textInputType ?? this.textInputType,
      isPassword: isPassword ?? this.isPassword,
    );
  }
}
