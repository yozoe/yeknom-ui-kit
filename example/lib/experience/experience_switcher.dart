import 'package:flutter/material.dart';

import 'example_experience.dart';

class ExperienceSwitcher extends StatelessWidget {
  const ExperienceSwitcher({
    required this.current,
    required this.onChanged,
    super.key,
    this.compact = false,
  });

  final ExampleExperience current;
  final ValueChanged<ExampleExperience> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.textScalerOf(context);
    final labelStyle =
        Theme.of(
          context,
        ).textButtonTheme.style?.textStyle?.resolve(const <WidgetState>{}) ??
        Theme.of(context).textTheme.labelLarge ??
        const TextStyle(fontSize: 14);
    final direction = Directionality.of(context);

    double labelWidth(String label) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: direction,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      return painter.width;
    }

    final widestLabel = ExampleExperience.values
        .map((experience) => labelWidth(experience.label))
        .reduce((first, second) => first > second ? first : second);

    Widget option(ExampleExperience experience, {required bool showIcon}) {
      final selected = experience == current;
      final style = TextButton.styleFrom(
        minimumSize: Size(0, compact ? 38 : 44),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: 8,
        ),
        foregroundColor: selected
            ? scheme.onPrimaryContainer
            : scheme.onSurfaceVariant,
        backgroundColor: selected
            ? scheme.primaryContainer
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 9 : 13),
        ),
      );
      final label = Text(experience.label, maxLines: 1, softWrap: false);
      final button = showIcon
          ? TextButton.icon(
              onPressed: () => onChanged(experience),
              style: style,
              icon: Icon(experience.icon, size: compact ? 15 : 17),
              label: label,
            )
          : TextButton(
              onPressed: () => onChanged(experience),
              style: style,
              child: label,
            );
      return Semantics(
        key: ValueKey('experience_${experience.name}'),
        container: true,
        label: experience.label,
        button: true,
        selected: selected,
        enabled: true,
        onTap: () => onChanged(experience),
        excludeSemantics: true,
        child: button,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final optionWidth = (constraints.maxWidth - 6) / 2;
        final horizontalPadding = compact ? 12.0 : 20.0;
        const measurementSafety = 8.0;
        final stack =
            optionWidth < widestLabel + horizontalPadding + measurementSafety;
        final showIcons =
            stack ||
            optionWidth >=
                widestLabel +
                    horizontalPadding +
                    (compact ? 15 : 17) +
                    8 +
                    measurementSafety;
        final options = [
          for (final experience in ExampleExperience.values)
            option(experience, showIcon: showIcons),
        ];

        return Semantics(
          container: true,
          label: '界面体验',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: stack
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (
                          var index = 0;
                          index < options.length;
                          index++
                        ) ...[
                          options[index],
                          if (index < options.length - 1)
                            const SizedBox(height: 3),
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        for (final item in options) Expanded(child: item),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
