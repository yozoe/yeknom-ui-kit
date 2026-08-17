import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';

@immutable
class YeknomDropdownOption<T> {
  const YeknomDropdownOption({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;
}

/// A form-compatible dropdown with a consistent field and option layout.
class YeknomDropdown<T> extends StatelessWidget {
  const YeknomDropdown({
    required this.options,
    super.key,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.decoration = const InputDecoration(),
    this.hint,
    this.focusNode,
    this.autofocus = false,
    this.menuMaxHeight = 320,
    this.enabled = true,
  });

  final List<YeknomDropdownOption<T>> options;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration decoration;
  final Widget? hint;
  final FocusNode? focusNode;
  final bool autofocus;
  final double? menuMaxHeight;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final effectiveEnabled =
        enabled &&
        decoration.enabled &&
        onChanged != null &&
        options.any((option) => option.enabled);
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: effectiveEnabled ? palette.trace : palette.muted,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
    final effectiveDecoration = decoration.copyWith(
      enabled: effectiveEnabled,
      filled: true,
      fillColor: decoration.fillColor ?? palette.field,
    );

    return DropdownButtonFormField<T>(
      // `value` is kept until the package's minimum Flutter version includes
      // DropdownButtonFormField.initialValue.
      // ignore: deprecated_member_use
      value: initialValue,
      items: [
        for (final option in options)
          DropdownMenuItem<T>(
            value: option.value,
            enabled: option.enabled,
            child: _YeknomDropdownOptionView<T>(
              option: option,
              dropdownEnabled: effectiveEnabled,
            ),
          ),
      ],
      onChanged: effectiveEnabled ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: effectiveDecoration,
      hint: hint,
      focusNode: focusNode,
      autofocus: autofocus,
      isExpanded: true,
      itemHeight: 48,
      menuMaxHeight: menuMaxHeight,
      dropdownColor: palette.module,
      borderRadius: YeknomRadii.medium,
      elevation: 12,
      style: textStyle,
      icon: _YeknomDropdownChevron(enabled: effectiveEnabled),
    );
  }
}

class _YeknomDropdownOptionView<T> extends StatelessWidget {
  const _YeknomDropdownOptionView({
    required this.option,
    required this.dropdownEnabled,
  });

  final YeknomDropdownOption<T> option;
  final bool dropdownEnabled;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final optionEnabled = dropdownEnabled && option.enabled;
    return Row(
      children: [
        if (option.leading != null) ...[
          IconTheme.merge(
            data: IconThemeData(
              color: optionEnabled ? palette.muted : palette.faint,
              size: 18,
            ),
            child: option.leading!,
          ),
          const SizedBox(width: YeknomSpacing.sm),
        ],
        Expanded(
          child: Text(
            option.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: optionEnabled ? palette.trace : palette.faint,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _YeknomDropdownChevron extends StatelessWidget {
  const _YeknomDropdownChevron({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsetsDirectional.only(end: YeknomSpacing.sm),
      decoration: BoxDecoration(
        color: palette.raised,
        border: Border.all(color: palette.border),
        borderRadius: YeknomRadii.compact,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.unfold_more_rounded,
        size: 16,
        color: enabled ? palette.muted : palette.faint,
      ),
    );
  }
}
