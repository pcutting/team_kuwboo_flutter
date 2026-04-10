import 'package:flutter/material.dart';
import '../theme/proto_theme.dart';

// ─── ProtoAvatar ──────────────────────────────────────────────────────────────
// Replaces CircleAvatar(backgroundImage: NetworkImage(...)) with loading/error
// fallback. Shows a themed placeholder icon when the image fails to load.

class ProtoAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final IconData fallbackIcon;

  const ProtoAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.primary.withValues(alpha: 0.1),
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      child: _ErrorFallback(
        imageUrl: imageUrl,
        icon: fallbackIcon,
        size: radius,
      ),
    );
  }
}

class _ErrorFallback extends StatefulWidget {
  final String imageUrl;
  final IconData icon;
  final double size;

  const _ErrorFallback({
    required this.imageUrl,
    required this.icon,
    required this.size,
  });

  @override
  State<_ErrorFallback> createState() => _ErrorFallbackState();
}

class _ErrorFallbackState extends State<_ErrorFallback> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkImage();
  }

  @override
  void didUpdateWidget(_ErrorFallback old) {
    super.didUpdateWidget(old);
    if (old.imageUrl != widget.imageUrl) {
      _hasError = false;
      _checkImage();
    }
  }

  void _checkImage() {
    final stream = NetworkImage(widget.imageUrl).resolve(
      ImageConfiguration.empty,
    );
    stream.addListener(ImageStreamListener(
      (_, __) {
        if (mounted && _hasError) setState(() => _hasError = false);
      },
      onError: (_, __) {
        if (mounted) setState(() => _hasError = true);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasError) return const SizedBox.shrink();
    final theme = ProtoTheme.of(context);
    return Icon(
      widget.icon,
      size: widget.size * 0.8,
      color: theme.textTertiary,
    );
  }
}

// ─── ProtoNetworkImage ────────────────────────────────────────────────────────
// Replaces Image.network(...) with loading placeholder and error fallback.

class ProtoNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProtoNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);

    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: theme.surface,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.textTertiary,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        return Container(
          width: width,
          height: height,
          color: theme.surface,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.textTertiary,
              size: 24,
            ),
          ),
        );
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

// ─── ProtoImageContainer ──────────────────────────────────────────────────────
// Replaces Container(decoration: BoxDecoration(image: DecorationImage(...)))
// with error handling. Wraps a Container that falls back to a placeholder
// when the network image fails.

class ProtoImageContainer extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? child;
  final AlignmentGeometry? alignment;

  const ProtoImageContainer({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.child,
    this.alignment,
  });

  @override
  State<ProtoImageContainer> createState() => _ProtoImageContainerState();
}

class _ProtoImageContainerState extends State<ProtoImageContainer> {
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProtoImageContainer old) {
    super.didUpdateWidget(old);
    if (old.imageUrl != widget.imageUrl) {
      _hasError = false;
      _isLoading = true;
      _loadImage();
    }
  }

  void _loadImage() {
    final stream = NetworkImage(widget.imageUrl).resolve(
      ImageConfiguration.empty,
    );
    stream.addListener(ImageStreamListener(
      (_, __) {
        if (mounted) setState(() => _isLoading = false);
      },
      onError: (_, __) {
        if (mounted) setState(() { _hasError = true; _isLoading = false; });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProtoTheme.of(context);
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: _hasError || _isLoading ? theme.surface : null,
        image: _hasError
            ? null
            : DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: widget.fit,
                onError: (_, __) {
                  if (mounted) setState(() => _hasError = true);
                },
              ),
      ),
      child: _hasError
          ? Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: theme.textTertiary,
                size: 24,
              ),
            )
          : widget.child,
    );
  }
}
