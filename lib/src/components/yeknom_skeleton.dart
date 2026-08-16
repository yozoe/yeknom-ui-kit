import 'package:flutter/material.dart';

import '../foundation/yeknom_palette.dart';
import '../foundation/yeknom_tokens.dart';
import 'yeknom_surface.dart';

class YeknomSkeleton extends StatefulWidget {
  const YeknomSkeleton({
    required this.height,
    super.key,
    this.width = double.infinity,
    this.borderRadius = YeknomRadii.compact,
    this.semanticLabel,
    this.duration = const Duration(milliseconds: 1300),
  });

  const YeknomSkeleton.line({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.borderRadius = YeknomRadii.pill,
    this.semanticLabel,
    this.duration = const Duration(milliseconds: 1300),
  });

  const YeknomSkeleton.circle({
    required double size,
    Key? key,
    String? semanticLabel,
    Duration duration = const Duration(milliseconds: 1300),
  }) : this(
         key: key,
         width: size,
         height: size,
         borderRadius: YeknomRadii.pill,
         semanticLabel: semanticLabel,
         duration: duration,
       );

  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final String? semanticLabel;
  final Duration duration;

  @override
  State<YeknomSkeleton> createState() => _YeknomSkeletonState();
}

class _YeknomSkeletonState extends State<YeknomSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationsDisabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(YeknomSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    _animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final base = palette.field;
    final highlight = palette.raised;
    final skeleton = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _animationsDisabled ? 0.0 : _controller.value * 4 - 2;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(offset - 1, 0),
              end: Alignment(offset + 1, 0),
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
    if (widget.semanticLabel == null) {
      return ExcludeSemantics(child: skeleton);
    }
    return Semantics(label: widget.semanticLabel, child: skeleton);
  }
}

class YeknomLoadingView extends StatelessWidget {
  const YeknomLoadingView({
    required this.semanticLabel,
    super.key,
    this.title,
    this.message,
    this.progress,
    this.panelled = false,
    this.maxWidth = 440,
  });

  final String? title;
  final String? message;
  final double? progress;
  final bool panelled;
  final double maxWidth;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = YeknomPalette.of(context);
    final content = Semantics(
      label: semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(value: progress, strokeWidth: 2),
          ),
          if (title case final title?) ...[
            const SizedBox(height: YeknomSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
          if (message case final message?) ...[
            const SizedBox(height: YeknomSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.muted),
            ),
          ],
        ],
      ),
    );
    final body = panelled
        ? YeknomSurface(
            padding: const EdgeInsets.all(YeknomSpacing.xl),
            borderRadius: YeknomRadii.medium,
            child: content,
          )
        : content;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(YeknomSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: body,
        ),
      ),
    );
  }
}
