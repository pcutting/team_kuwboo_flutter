import 'package:json_annotation/json_annotation.dart';

/// Media asset type. Mirrors `apps/api/src/common/enums/media-type.enum.ts`.
@JsonEnum(valueField: 'value')
enum MediaType {
  image('IMAGE'),
  video('VIDEO'),
  audio('AUDIO');

  const MediaType(this.value);
  final String value;

  static MediaType fromJson(String raw) =>
      MediaType.values.firstWhere((e) => e.value == raw);
  String toJson() => value;
}

/// Media upload lifecycle status. Mirrors backend `MediaStatus` enum
/// (PROCESSING → READY or FAILED). Backend also includes an implicit
/// DELETED state used by future soft-delete flows — included for
/// forward compatibility.
@JsonEnum(valueField: 'value')
enum MediaStatus {
  pending('PROCESSING'),
  ready('READY'),
  failed('FAILED'),
  deleted('DELETED');

  const MediaStatus(this.value);
  final String value;

  static MediaStatus fromJson(String raw) =>
      MediaStatus.values.firstWhere((e) => e.value == raw);
  String toJson() => value;
}

/// Client-side upload size caps. Must match
/// `apps/api/src/modules/media/media.service.ts` SIZE_LIMITS.
class MediaLimits {
  MediaLimits._();

  static const int imageMaxBytes = 10 * 1024 * 1024;
  static const int audioMaxBytes = 20 * 1024 * 1024;
  static const int videoMaxBytes = 100 * 1024 * 1024;

  /// Content-type whitelist per media type. Must match backend
  /// `ALLOWED_CONTENT_TYPES` in `media.service.ts`.
  static const List<String> imageContentTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  ];

  static const List<String> videoContentTypes = [
    'video/mp4',
    'video/quicktime',
    'video/webm',
  ];

  static const List<String> audioContentTypes = [
    'audio/mpeg',
    'audio/aac',
    'audio/wav',
    'audio/m4a',
  ];

  static int maxBytesFor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return imageMaxBytes;
      case MediaType.video:
        return videoMaxBytes;
      case MediaType.audio:
        return audioMaxBytes;
    }
  }

  static List<String> contentTypesFor(MediaType type) {
    switch (type) {
      case MediaType.image:
        return imageContentTypes;
      case MediaType.video:
        return videoContentTypes;
      case MediaType.audio:
        return audioContentTypes;
    }
  }

  /// Returns null if valid, or a human-readable error string otherwise.
  /// Use to short-circuit before calling the presigned-url endpoint.
  static String? validate({
    required MediaType type,
    required String contentType,
    required int sizeBytes,
  }) {
    final allowed = contentTypesFor(type);
    if (!allowed.contains(contentType)) {
      return 'Content type "$contentType" not allowed for ${type.value}';
    }
    final max = maxBytesFor(type);
    if (sizeBytes <= 0) {
      return 'File size must be greater than zero';
    }
    if (sizeBytes > max) {
      return 'File too large. Max ${max ~/ (1024 * 1024)}MB for ${type.value}';
    }
    return null;
  }
}

/// Request body for `POST /media/presigned-url`.
class PresignedUrlRequestDto {
  const PresignedUrlRequestDto({
    required this.fileName,
    required this.contentType,
    required this.type,
    required this.sizeBytes,
  });

  final String fileName;
  final String contentType;
  final MediaType type;
  final int sizeBytes;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'contentType': contentType,
        'type': type.value,
        'sizeBytes': sizeBytes,
      };
}

/// Response body for `POST /media/presigned-url`.
class PresignedUrlResponse {
  const PresignedUrlResponse({
    required this.uploadUrl,
    required this.mediaId,
    required this.s3Key,
  });

  final String uploadUrl;
  final String mediaId;
  final String s3Key;

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      PresignedUrlResponse(
        uploadUrl: json['uploadUrl'] as String,
        mediaId: json['mediaId'] as String,
        s3Key: json['s3Key'] as String,
      );
}

/// Media record as returned by the backend (e.g. from `POST /media/:id/confirm`).
/// Mirrors `apps/api/src/modules/media/entities/media.entity.ts`.
class Media {
  const Media({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.s3Key,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    required this.createdAt,
    this.cdnUrl,
  });

  final String id;

  /// Maps to backend `uploader.id` — the user that created the upload.
  final String ownerId;
  final MediaType type;
  final String s3Key;

  /// Public CDN/S3 URL. Null until upload is confirmed (status != READY).
  final String? cdnUrl;
  final String contentType;
  final int sizeBytes;
  final MediaStatus status;
  final DateTime createdAt;

  factory Media.fromJson(Map<String, dynamic> json) {
    // Backend entity uses `uploader` relation and `mimeType` / `url` fields.
    final uploader = json['uploader'];
    final ownerId = (json['ownerId'] as String?) ??
        (json['uploaderId'] as String?) ??
        (uploader is Map<String, dynamic>
            ? uploader['id'] as String
            : uploader as String? ?? '');
    return Media(
      id: json['id'] as String,
      ownerId: ownerId,
      type: MediaType.fromJson(json['type'] as String),
      s3Key: json['s3Key'] as String,
      cdnUrl: (json['cdnUrl'] as String?) ?? (json['url'] as String?),
      contentType:
          (json['contentType'] as String?) ?? json['mimeType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      status: MediaStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
