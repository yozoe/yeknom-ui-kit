import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YeknomTextField extends StatelessWidget {
  const YeknomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.enabled,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.scrollPadding = const EdgeInsets.all(20),
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TapRegionCallback? onTapOutside;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      autofocus: autofocus,
      readOnly: readOnly,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      onTap: onTap,
      onTapOutside: onTapOutside,
      scrollPadding: scrollPadding,
    );
  }
}

class YeknomSearchField extends StatefulWidget {
  const YeknomSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.decoration = const InputDecoration(),
    this.autofocus = false,
    this.enabled = true,
    this.showClearButton = true,
    this.clearTooltip,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final InputDecoration decoration;
  final bool autofocus;
  final bool enabled;
  final bool showClearButton;
  final String? clearTooltip;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  State<YeknomSearchField> createState() => _YeknomSearchFieldState();
}

class _YeknomSearchFieldState extends State<YeknomSearchField> {
  late TextEditingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(YeknomSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController(TextEditingController? controller) {
    _ownsController = controller == null;
    _controller = controller ?? TextEditingController();
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final clearButton = widget.showClearButton && _controller.text.isNotEmpty
        ? IconButton(
            onPressed: widget.enabled ? _clear : null,
            tooltip: widget.clearTooltip,
            icon: const Icon(Icons.close_rounded, size: 18),
          )
        : null;
    final decoration = widget.decoration.copyWith(
      hintText: widget.decoration.hintText ?? widget.hintText,
      prefixIcon:
          widget.decoration.prefixIcon ??
          const Icon(Icons.search_rounded, size: 19),
      suffixIcon: widget.decoration.suffixIcon ?? clearButton,
    );

    return YeknomTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      decoration: decoration,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
